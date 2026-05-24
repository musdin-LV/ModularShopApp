// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CartFeature",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "CartFeature", targets: ["CartFeature"])
    ],
    dependencies: [
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../ProductFeature")
    ],
    targets: [
        .target(
            name: "CartFeature",
            dependencies: [
                "DesignSystem",
                "ProductFeature"
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "CartFeatureTests",
            dependencies: ["CartFeature"]
        )
    ],
    swiftLanguageModes: [.v6]
)
