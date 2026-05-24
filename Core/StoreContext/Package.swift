// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "StoreContext",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "StoreContext", targets: ["StoreContext"])
    ],
    dependencies: [
        .package(path: "../Networking")
    ],
    targets: [
        .target(
            name: "StoreContext",
            dependencies: [
                "Networking"
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "StoreContextTests",
            dependencies: ["StoreContext"]
        )
    ],
    swiftLanguageModes: [.v6]
)
