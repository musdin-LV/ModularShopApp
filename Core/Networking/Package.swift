// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v18),
        .macOS(.v13)
    ],
    products: [
        .library(name: "Networking", targets: ["Networking"])
    ],
    targets: [
        .target(
            name: "Networking",
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]
        )
    ],
    swiftLanguageModes: [.v6]
)
