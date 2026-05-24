// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Observability",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "Observability", targets: ["Observability"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "12.13.0")
        )
    ],
    targets: [
        .target(
            name: "Observability",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "ObservabilityTests",
            dependencies: ["Observability"]
        )
    ],
    swiftLanguageModes: [.v6]
)
