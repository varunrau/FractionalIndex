// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FractionalIndex",
    products: [
        .library(
            name: "FractionalIndex",
            targets: ["FractionalIndex"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FractionalIndex",
            dependencies: []),
        .testTarget(
            name: "FractionalIndexTests",
            dependencies: ["FractionalIndex"]),
    ]
)
