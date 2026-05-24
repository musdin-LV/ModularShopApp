// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FeatureFlags",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "FeatureFlags", targets: ["FeatureFlags"])
    ],
    dependencies: [
        .package(path: "../Networking")
    ],
    targets: [
        .target(
            name: "FeatureFlags",
            dependencies: [
                "Networking"
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "FeatureFlagsTests",
            dependencies: [
                "FeatureFlags",
                "Networking"
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
