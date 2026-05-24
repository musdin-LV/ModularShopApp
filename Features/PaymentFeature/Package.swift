// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PaymentFeature",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "PaymentFeature", targets: ["PaymentFeature"])
    ],
    dependencies: [
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/Networking"),
        .package(path: "../../Core/Observability")
    ],
    targets: [
        .target(
            name: "PaymentFeature",
            dependencies: [
                "DesignSystem",
                "Networking",
                "Observability"
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "PaymentFeatureTests",
            dependencies: ["PaymentFeature"]
        )
    ],
    swiftLanguageModes: [.v6]
)
