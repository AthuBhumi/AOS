import os
import uuid

def generate_id():
    return uuid.uuid4().hex[:24].upper()

def main():
    repo_root = os.path.dirname(os.path.abspath(__file__))
    source_dirs = [
        "App", "Core", "Models", "Storage", "Repositories", "AI", "Authentication",
        "Business", "Coding", "Common", "Company", "DailyMission", "Dashboard",
        "Finance", "Goals", "Habits", "Journal", "Logging", "Networking",
        "Profile", "Reading", "Security"
    ]

    swift_files = []
    for sdir in source_dirs:
        dir_path = os.path.join(repo_root, sdir)
        if os.path.exists(dir_path):
            for root, dirs, files in os.walk(dir_path):
                for f in files:
                    if f.endswith('.swift'):
                        rel_path = os.path.relpath(os.path.join(root, f), repo_root).replace('\\', '/')
                        swift_files.append(rel_path)

    print(f"Found {len(swift_files)} Swift source files.")

    # PBX Objects
    file_refs = {}
    build_files = {}

    for fpath in swift_files:
        file_ref_id = generate_id()
        build_file_id = generate_id()
        file_refs[fpath] = file_ref_id
        build_files[fpath] = build_file_id

    # Create Group Hierarchy
    dir_groups = {}
    for fpath in swift_files:
        parts = fpath.split('/')
        if len(parts) > 1:
            group_name = parts[0]
            if group_name not in dir_groups:
                dir_groups[group_name] = []
            dir_groups[group_name].append(fpath)

    # Generate PBX Sections
    pbx_file_refs = []
    pbx_build_files = []
    pbx_sources = []
    pbx_groups = []

    for fpath in swift_files:
        fname = os.path.basename(fpath)
        fref = file_refs[fpath]
        bfid = build_files[fpath]
        pbx_file_refs.append(f'\t\t{fref} /* {fname} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{fname}"; sourceTree = "<group>"; }};')
        pbx_build_files.append(f'\t\t{bfid} /* {fname} in Sources */ = {{isa = PBXBuildFile; fileRef = {fref} /* {fname} */; }};')
        pbx_sources.append(f'\t\t\t\t{bfid} /* {fname} in Sources */,')

    # Sub-groups
    sub_group_ids = {}
    for gname, fpaths in dir_groups.items():
        gid = generate_id()
        sub_group_ids[gname] = gid
        children_lines = []
        for fp in fpaths:
            children_lines.append(f'\t\t\t\t{file_refs[fp]} /* {os.path.basename(fp)} */,')
        pbx_groups.append(
            f'\t\t{gid} /* {gname} */ = {{\n'
            f'\t\t\tisa = PBXGroup;\n'
            f'\t\t\tchildren = (\n'
            + '\n'.join(children_lines) + '\n'
            f'\t\t\t);\n'
            f'\t\t\tname = {gname};\n'
            f'\t\t\tpath = {gname};\n'
            f'\t\t\tsourceTree = "<group>";\n'
            f'\t\t}};'
        )

    # Main Group
    main_group_id = generate_id()
    main_children = [f'\t\t\t\t{gid} /* {gname} */,' for gname, gid in sub_group_ids.items()]
    
    # Add Info.plist reference
    info_plist_ref = generate_id()
    pbx_file_refs.append(f'\t\t{info_plist_ref} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "App/Info.plist"; sourceTree = "<group>"; }};')
    main_children.append(f'\t\t\t\t{info_plist_ref} /* Info.plist */,')

    main_group_section = (
        f'\t\t{main_group_id} = {{\n'
        f'\t\t\tisa = PBXGroup;\n'
        f'\t\t\tchildren = (\n'
        + '\n'.join(main_children) + '\n'
        f'\t\t\t);\n'
        f'\t\t\tsourceTree = "<group>";\n'
        f'\t\t}};'
    )
    pbx_groups.append(main_group_section)

    # Build Configuration IDs
    proj_config_debug = generate_id()
    proj_config_release = generate_id()
    target_config_debug = generate_id()
    target_config_release = generate_id()
    proj_config_list = generate_id()
    target_config_list = generate_id()

    # Targets & Phased Builds
    target_id = generate_id()
    sources_phase_id = generate_id()
    frameworks_phase_id = generate_id()
    project_id = generate_id()

    content = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
{chr(10).join(pbx_build_files)}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{chr(10).join(pbx_file_refs)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{frameworks_phase_id} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{chr(10).join(pbx_groups)}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{target_id} /* ATHARVA_OS */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {target_config_list} /* Build configuration list for PBXNativeTarget "ATHARVA_OS" */;
			buildPhases = (
				{sources_phase_id} /* Sources */,
				{frameworks_phase_id} /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = ATHARVA_OS;
			productName = ATHARVA_OS;
			productReference = {generate_id()} /* ATHARVA_OS.app */;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{project_id} /* Project Object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1540;
				LastUpgradeCheck = 1540;
				TargetAttributes = {{
					{target_id} = {{
						CreatedOnToolsVersion = 15.4;
					}};
				}};
			}};
			buildConfigurationList = {proj_config_list} /* Build configuration list for PBXProject "ATHARVA_OS" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {main_group_id};
			productRefGroup = {main_group_id};
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{target_id} /* ATHARVA_OS */,
			);
		}};
/* End PBXProject section */

/* Begin PBXSourcesBuildPhase section */
		{sources_phase_id} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{chr(10).join(pbx_sources)}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		{proj_config_debug} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CODE_SIGN_IDENTITY = "";
				CODE_SIGNING_ALLOWED = NO;
				CODE_SIGNING_REQUIRED = NO;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				SDKROOT = iphoneos;
				SWIFT_VERSION = 5.0;
			}};
			name = Debug;
		}};
		{proj_config_release} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CODE_SIGN_IDENTITY = "";
				CODE_SIGNING_ALLOWED = NO;
				CODE_SIGNING_REQUIRED = NO;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				SDKROOT = iphoneos;
				SWIFT_VERSION = 5.0;
			}};
			name = Release;
		}};
		{target_config_debug} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = "ATHARVA OS";
				INFOPLIST_KEY_LSRequiresIPhoneOS = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.atharva.aos;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{target_config_release} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = "ATHARVA OS";
				INFOPLIST_KEY_LSRequiresIPhoneOS = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.atharva.aos;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{proj_config_list} /* Build configuration list for PBXProject "ATHARVA_OS" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{proj_config_debug} /* Debug */,
				{proj_config_release} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{target_config_list} /* Build configuration list for PBXNativeTarget "ATHARVA_OS" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{target_config_debug} /* Debug */,
				{target_config_release} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */
	}};
	rootObject = {project_id} /* Project Object */;
}}
"""

    proj_dir = os.path.join(repo_root, "ATHARVA_OS.xcodeproj")
    os.makedirs(proj_dir, exist_ok=True)
    with open(os.path.join(proj_dir, "project.pbxproj"), "w", encoding="utf-8") as f:
        f.write(content)

    print(f"Successfully generated Xcode project at: {proj_dir}")

if __name__ == "__main__":
    main()
