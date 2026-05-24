// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FavoritesFeature",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "FavoritesFeature", targets: ["FavoritesFeature"])
    ],
    dependencies: [
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../ProductFeature")
    ],
    targets: [
        .target(
            name: "FavoritesFeature",
            dependencies: [
                "DesignSystem",
                "ProductFeature"
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "FavoritesFeatureTests",
            dependencies: ["FavoritesFeature"]
        )
    ],
    swiftLanguageModes: [.v6]
)
