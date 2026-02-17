// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DXBCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DXBCore", targets: ["DXBCore"])
    ],
    targets: [
        .target(name: "DXBCore")
    ]
)
