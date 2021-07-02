// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "TabulaKit",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(
            name: "TabulaTool",
            targets: ["TabulaTool"]
        ),
        .library(
            name: "TabulaKit",
            targets: ["TabulaKit"]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:pvieito/LoggerKit.git", .branch("master")),
        .package(url: "git@github.com:pvieito/FoundationKit.git", .branch("master")),
        .package(url: "git@github.com:pvieito/PythonKit.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.1")),
    ],
    targets: [
        .target(
            name: "TabulaTool",
            dependencies: ["LoggerKit", "FoundationKit", "TabulaKit", "PythonKit", .product(name: "ArgumentParser", package: "swift-argument-parser")],
            path: "TabulaTool"
        ),
        .target(
            name: "TabulaKit",
            dependencies: ["FoundationKit"],
            path: "TabulaKit",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "TabulaKitTests",
            dependencies: ["TabulaKit", "FoundationKit"],
            resources: [.process("Resources")]
        )
    ]
)
