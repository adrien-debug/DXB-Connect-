// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DXBCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DXBCore",
            targets: ["DXBCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DXBCore",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "DXBCoreTests",
            dependencies: ["DXBCore"],
            path: "Tests"
        ),
    ]
)
