// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EmotiTask",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "EmotiTask",
            targets: ["EmotiTask"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "EmotiTask",
            dependencies: []),
    ]
) 