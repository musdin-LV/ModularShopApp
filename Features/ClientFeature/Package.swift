// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ClientFeature",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "ClientFeature", targets: ["ClientFeature"])
    ],
    dependencies: [
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/Networking")
    ],
    targets: [
        .target(
            name: "ClientFeature",
            dependencies: [
                "DesignSystem",
                "Networking"
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "ClientFeatureTests",
            dependencies: ["ClientFeature"]
        )
    ],
    swiftLanguageModes: [.v6]
)
