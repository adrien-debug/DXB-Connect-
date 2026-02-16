// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DXBAdminKit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DXBAdminKit",
            targets: ["DXBAdminKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DXBAdminKit",
            dependencies: [],
            path: "Sources"
        ),
    ]
)
