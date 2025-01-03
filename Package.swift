// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "surreal-interactive-openxr-framework",
    platforms: [
	.visionOS(.v2)
    ],
    products: [
        .library(
            name: "surreal-interactive-openxr-framework",
            targets: ["surreal-interactive-openxr-framework"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "surreal-interactive-openxr-framework",
            path: "surreal-interactive-openxr-framework.xcframework"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
