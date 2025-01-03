// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SurrealTouchSDK",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SurrealTouchSDK",
            targets: ["surreal-interactive-openxr-framework"]),
    ],
    targets: [
        .binaryTarget(
            name: "surreal-interactive-openxr-framework",
            path: "Sources/surreal-interactive-openxr-framework.xcframework"
        ),
    ]
)
