// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AuthFeature",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AuthFeature", targets: ["AuthFeature"])
    ],
    dependencies: [
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/Networking")
    ],
    targets: [
        .target(
            name: "AuthFeature",
            dependencies: [
                "DesignSystem",
                "Networking"
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "AuthFeatureTests",
            dependencies: ["AuthFeature"]
        )
    ],
    swiftLanguageModes: [.v6]
)
