// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AOS",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AOSLib", targets: [
            "Core", "Logging", "Common", "Models", "Storage", "Networking", "Security",
            "Repositories", "AI", "Business", "Coding", "Company",
            "DailyMission", "Dashboard", "Finance", "Goals", "Habits",
            "Journal", "Profile", "Reading", "Authentication"
        ]),
        .executable(name: "AOS", targets: ["App"])
    ],
    dependencies: [],
    targets: [
        // ── App Entry Point ──
        .executableTarget(
            name: "App",
            dependencies: [
                "Core", "Logging", "Common", "Models", "Storage", "Networking", "Security",
                "Repositories", "AI", "Authentication", "Business", "Coding", "Company",
                "DailyMission", "Dashboard", "Finance", "Goals", "Habits",
                "Journal", "Profile", "Reading"
            ],
            path: "App"
        ),

        // ── Foundation Layer ──
        .target(name: "Core", path: "Core"),
        .target(name: "Logging", path: "Logging"),
        .target(name: "Common", dependencies: ["Logging"], path: "Common"),
        .target(name: "Security", path: "Security"),
        .target(name: "Networking", path: "Networking"),

        // ── Data Layer ──
        .target(name: "Models", dependencies: ["Core"], path: "Models"),
        .target(name: "Storage", dependencies: ["Models"], path: "Storage"),

        // ── Repository Layer ──
        .target(name: "Repositories", dependencies: ["Models", "Storage", "Logging", "Common"], path: "Repositories"),

        // ── Feature Modules ──
        .target(name: "AI", dependencies: ["Models", "Repositories", "Common"], path: "AI"),
        .target(name: "Authentication", dependencies: ["Models", "Repositories", "Security"], path: "Authentication"),
        .target(name: "Business", dependencies: ["Models", "Repositories", "Common"], path: "Business"),
        .target(name: "Coding", dependencies: ["Models", "Repositories", "Networking"], path: "Coding"),
        .target(name: "Company", dependencies: ["Models", "Repositories", "Common"], path: "Company"),
        .target(name: "DailyMission", dependencies: ["Models", "Repositories", "Common"], path: "DailyMission"),
        .target(name: "Dashboard", dependencies: ["Models", "Repositories", "Common", "AI", "Finance", "Business", "Company"], path: "Dashboard"),
        .target(name: "Finance", dependencies: ["Models", "Repositories", "Common"], path: "Finance"),
        .target(name: "Goals", dependencies: ["Models", "Repositories", "Common"], path: "Goals"),
        .target(name: "Habits", dependencies: ["Models", "Repositories", "Common"], path: "Habits"),
        .target(name: "Journal", dependencies: ["Models", "Repositories", "Common"], path: "Journal"),
        .target(name: "Profile", dependencies: ["Models", "Repositories", "Common"], path: "Profile"),
        .target(name: "Reading", dependencies: ["Models", "Repositories", "Common"], path: "Reading"),

        // ── Tests ──
        .testTarget(
            name: "AOSTests",
            dependencies: [
                "Core", "Common", "Models", "Storage", "Repositories",
                "AI", "Finance", "Business", "Reading", "Company", "Dashboard"
            ],
            path: "Testing"
        )
    ]
)
