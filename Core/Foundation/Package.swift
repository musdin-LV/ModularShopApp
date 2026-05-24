// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ShopFoundation",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "ShopFoundation", targets: ["ShopFoundation"])
    ],
    targets: [
        .target(
            name: "ShopFoundation",
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
