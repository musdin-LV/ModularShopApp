// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ProductFeature",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "ProductFeature", targets: ["ProductFeature"])
    ],
    dependencies: [
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/Networking")
    ],
    targets: [
        .target(
            name: "ProductFeature",
            dependencies: [
                "DesignSystem",
                "Networking"
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "ProductFeatureTests",
            dependencies: ["ProductFeature"]
        )
    ],
    swiftLanguageModes: [.v6]
)
