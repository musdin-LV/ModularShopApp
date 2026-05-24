// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "HomeFeature",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "HomeFeature", targets: ["HomeFeature"])
    ],
    dependencies: [
        .package(path: "../../Core/DesignSystem")
    ],
    targets: [
        .target(
            name: "HomeFeature",
            dependencies: ["DesignSystem"],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
