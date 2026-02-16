// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DXBConnect",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "DXBCore", targets: ["DXBCore"]),
        .library(name: "DXBAdminKit", targets: ["DXBAdminKit"]),
    ],
    dependencies: [],
    targets: [
        // DXBCore - Shared networking, models, auth
        .target(
            name: "DXBCore",
            dependencies: [],
            path: "Packages/DXBCore/Sources"
        ),
        // DXBAdminKit - Admin specific models
        .target(
            name: "DXBAdminKit",
            dependencies: ["DXBCore"],
            path: "Packages/DXBAdminKit/Sources"
        ),
        // Tests
        .testTarget(
            name: "DXBCoreTests",
            dependencies: ["DXBCore"],
            path: "Packages/DXBCore/Tests"
        ),
    ]
)
