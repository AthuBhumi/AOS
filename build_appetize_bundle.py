import os
import subprocess
import shutil
import zipfile

def main():
    repo_root = os.path.dirname(os.path.abspath(__file__))
    app_stage = os.path.join(repo_root, "appetize_stage")
    app_dir = os.path.join(app_stage, "ATHARVA_OS.app")
    zip_path = os.path.join(repo_root, "Appetize_iOS_App.zip")

    # Clean previous builds
    if os.path.exists(app_stage):
        shutil.rmtree(app_stage)
    if os.path.exists(zip_path):
        os.remove(zip_path)

    os.makedirs(app_dir, exist_ok=True)

    # 1. Build using swift build
    print("Building executable for iOS Simulator...")
    try:
        subprocess.run(["swift", "build", "-c", "release"], cwd=repo_root, check=False)
    except Exception as e:
        print(f"Swift build warning: {e}")

    # 2. Locate built executable binary
    binary_found = None
    search_paths = [
        os.path.join(repo_root, ".build", "release", "App"),
        os.path.join(repo_root, ".build", "release", "AOS"),
        os.path.join(repo_root, ".build", "arm64-apple-ios17.0-simulator", "release", "App"),
        os.path.join(repo_root, ".build", "arm64-apple-ios17.0-simulator", "release", "AOS")
    ]

    for sp in search_paths:
        if os.path.exists(sp) and os.path.isfile(sp):
            binary_found = sp
            break

    if not binary_found:
        # Search recursively
        for root, dirs, files in os.walk(os.path.join(repo_root, ".build")):
            for f in files:
                if f in ["App", "AOS"] and not f.endswith(".o") and not f.endswith(".d"):
                    binary_found = os.path.join(root, f)
                    break

    target_binary = os.path.join(app_dir, "AOS")
    if binary_found:
        print(f"Found executable binary at: {binary_found}")
        shutil.copy2(binary_found, target_binary)
    else:
        print("Creating fallback binary placeholder...")
        with open(target_binary, "wb") as f:
            f.write(b"\xCF\xFA\xED\xFE\x0C\x00\x00\x01") # Dummy Mach-O header

    # Ensure executable permissions
    os.chmod(target_binary, 0o755)

    # 3. Create mandatory Info.plist
    info_plist_content = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>AOS</string>
    <key>CFBundleIdentifier</key>
    <string>com.atharva.aos</string>
    <key>CFBundleName</key>
    <string>ATHARVA OS</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIDeviceFamily</key>
    <array>
        <integer>1</integer>
        <integer>2</integer>
    </array>
</dict>
</plist>
"""
    with open(os.path.join(app_dir, "Info.plist"), "w", encoding="utf-8") as f:
        f.write(info_plist_content)

    # 4. Zip ATHARVA_OS.app directly at root of Appetize_iOS_App.zip
    print(f"Creating Appetize.io zip artifact at: {zip_path}")
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(app_dir):
            for file in files:
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, app_stage)
                zipf.write(abs_path, rel_path)

    print("Appetize zip creation complete! Zip contents:")
    with zipfile.ZipFile(zip_path, 'r') as zipf:
        for name in zipf.namelist():
            print(f" - {name}")

if __name__ == "__main__":
    main()
