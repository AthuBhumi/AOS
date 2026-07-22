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

    print("=== Step 1: Building iOS Simulator App via xcodebuild ===")
    cmd = [
        "xcodebuild",
        "-scheme", "AOS",
        "-sdk", "iphonesimulator",
        "-configuration", "Release",
        "-derivedDataPath", derived_data,
        "CODE_SIGNING_ALLOWED=NO",
        "CODE_SIGNING_REQUIRED=NO",
        "build"
    ]
    
    res = subprocess.run(cmd, cwd=repo_root, capture_output=True, text=True)
    print("xcodebuild STDOUT:")
    print(res.stdout[-2000:] if len(res.stdout) > 2000 else res.stdout)
    
    if res.returncode != 0:
        print("xcodebuild STDERR:")
        print(res.stderr[-2000:] if len(res.stderr) > 2000 else res.stderr)

    print("=== Step 2: Searching for compiled .app folder ===")
    app_folder = None
    for root, dirs, files in os.walk(derived_data):
        for d in dirs:
            if d.endswith(".app"):
                candidate = os.path.join(root, d)
                if os.path.exists(os.path.join(candidate, "Info.plist")):
                    app_folder = candidate
                    break
        if app_folder:
            break

    if not app_folder:
        print("Searching across entire repo for any .app folder...")
        for root, dirs, files in os.walk(repo_root):
            if "DerivedData" in root or ".build" in root:
                for d in dirs:
                    if d.endswith(".app"):
                        candidate = os.path.join(root, d)
                        if os.path.exists(os.path.join(candidate, "Info.plist")):
                            app_folder = candidate
                            break
            if app_folder:
                break

    if not app_folder:
        print("ERROR: No compiled iOS .app bundle found!")
        sys.exit(1)

    print(f"FOUND REAL iOS .app BUNDLE AT: {app_folder}")
    print("Contents of .app bundle:")
    for f in os.listdir(app_folder):
        print(f" - {f}")

    parent_dir = os.path.dirname(app_folder)
    app_basename = os.path.basename(app_folder)

    print(f"=== Step 3: Zipping {app_basename} for Appetize.io ===")
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(app_folder):
            for file in files:
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, parent_dir)
                zipf.write(abs_path, rel_path)

    print(f"Appetize.io Zip file created successfully! File size: {os.path.getsize(zip_path)} bytes")
    with zipfile.ZipFile(zip_path, 'r') as zipf:
        print("Zip Root Directory Contents:")
        for item in zipf.namelist()[:10]:
            print(f"   {item}")

if __name__ == "__main__":
    main()
