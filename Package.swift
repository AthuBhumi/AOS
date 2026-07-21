// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AOS",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "AOSCore", targets: ["AOSCore"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AOSCore",
            path: ".",
            exclude: [
                "Testing",
                "ATHARVA_OS_SRS.md",
                "ATHARVA_OS_DB_ARCHITECTURE.md",
                "ATHARVA_OS_DESIGN_SYSTEM.md",
                "ATHARVA_OS_UI_BIBLE.md",
                "ATHARVA_OS_UX_BLUEPRINT.md",
                "ATHARVA_OS_PROJECT_ARCHITECTURE.md",
                "ATHARVA_OS_BACKEND_ARCHITECTURE.md",
                "ATHARVA_OS_AI_BRAIN_SPECIFICATION.md"
            ]
        ),
        .testTarget(
            name: "AOSTests",
            dependencies: ["AOSCore"],
            path: "Testing"
        )
    ]
)
