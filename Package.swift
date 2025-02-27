// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppStorys-iOS",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AppStorys-iOS",
            targets: ["AppStorys-iOS"]),
    ],
    targets: [
        .target(
            name: "AppStorys-iOS"),

    ]
)
