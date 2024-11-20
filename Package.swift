// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Flash",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Flash",
            targets: ["Flash"]),
    ],
    targets: [
        .target(
            name: "Flash"
        ),
    ]
)
