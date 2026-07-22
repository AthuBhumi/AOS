import os
import subprocess
import shutil
import zipfile
import sys

def main():
    repo_root = os.path.dirname(os.path.abspath(__file__))
    derived_data = os.path.join(repo_root, "DerivedData")
    zip_path = os.path.join(repo_root, "Appetize_iOS_App.zip")

    if os.path.exists(zip_path):
        os.remove(zip_path)

    print("=== Step 1: Building iOS Simulator Binary via xcodebuild ===")
    
    # 1. Try xcodebuild first
    cmd = [
        "xcodebuild",
        "-scheme", "AOS",
        "-sdk", "iphonesimulator",
        "-destination", "generic/platform=iOS Simulator",
        "-configuration", "Release",
        "-derivedDataPath", derived_data,
        "CODE_SIGNING_ALLOWED=NO",
        "CODE_SIGNING_REQUIRED=NO",
        "build"
    ]
    
    print(f"Executing: {' '.join(cmd)}")
    res = subprocess.run(cmd, cwd=repo_root, capture_output=True, text=True)
    print("xcodebuild output:")
    print(res.stdout[-2000:] if res.stdout else "No stdout")
    if res.stderr:
        print("xcodebuild errors:", res.stderr[-2000:])

    # 2. Search for compiled binary executable in DerivedData & .build
    binary_found = None
    search_dirs = [derived_data, os.path.join(repo_root, ".build")]
    
    for search_dir in search_dirs:
        if os.path.exists(search_dir):
            for root, dirs, files in os.walk(search_dir):
                for f in files:
                    if f in ["App", "AOS"] and not f.endswith(".o") and not f.endswith(".d") and not f.endswith(".swiftmodule"):
                        fpath = os.path.join(root, f)
                        if os.path.isfile(fpath) and os.path.getsize(fpath) > 1000:
                            binary_found = fpath
                            break
                if binary_found:
                    break

    if not binary_found:
        print("=== Trying fallback swift build ===")
        sb_cmd = ["swift", "build", "-c", "release"]
        res2 = subprocess.run(sb_cmd, cwd=repo_root, capture_output=True, text=True)
        print("swift build output:", res2.stdout[-1500:] if res2.stdout else "")
        if res2.stderr:
            print("swift build errors:", res2.stderr[-1500:])

        for root, dirs, files in os.walk(os.path.join(repo_root, ".build")):
            for f in files:
                if f in ["App", "AOS"] and not f.endswith(".o") and not f.endswith(".d"):
                    fpath = os.path.join(root, f)
                    if os.path.isfile(fpath) and os.path.getsize(fpath) > 1000:
                        binary_found = fpath
                        break
            if binary_found:
                break

    if not binary_found or os.path.getsize(binary_found) < 1000:
        print(f"ERROR: No valid compiled binary > 1KB found!")
        sys.exit(1)

    print(f"=== SUCCESS: Found real compiled binary ({os.path.getsize(binary_found)} bytes) at: {binary_found} ===")

    # Create .app directory
    stage_dir = os.path.join(repo_root, "appetize_stage")
    app_folder = os.path.join(stage_dir, "ATHARVA_OS.app")
    if os.path.exists(stage_dir):
        shutil.rmtree(stage_dir)
    os.makedirs(app_folder, exist_ok=True)

    target_binary = os.path.join(app_folder, "AOS")
    shutil.copy2(binary_found, target_binary)
    os.chmod(target_binary, 0o755)

    info_plist = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>AOS</string>
    <key>CFBundleIdentifier</key><string>com.atharva.aos</string>
    <key>CFBundleName</key><string>ATHARVA OS</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSRequiresIPhoneOS</key><true/>
    <key>UIDeviceFamily</key><array><integer>1</integer><integer>2</integer></array>
</dict>
</plist>"""
    with open(os.path.join(app_folder, "Info.plist"), "w", encoding="utf-8") as f:
        f.write(info_plist)

    print(f"=== Zipping {app_folder} into Appetize_iOS_App.zip ===")
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(app_folder):
            for file in files:
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, stage_dir)
                zipf.write(abs_path, rel_path)

    print(f"Appetize.io Zip created successfully! File size: {os.path.getsize(zip_path)} bytes")

if __name__ == "__main__":
    main()
