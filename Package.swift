// swift-tools-version:5.0

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
        .package(url: "https://github.com/pvieito/CommandLineKit.git", .branch("master")),
        .package(url: "https://github.com/pvieito/LoggerKit.git", .branch("master")),
        .package(url: "https://github.com/pvieito/FoundationKit.git", .branch("master")),
        .package(url: "https://github.com/pvieito/PythonKit.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "TabulaTool",
            dependencies: ["LoggerKit", "FoundationKit", "CommandLineKit", "TabulaKit", "PythonKit"],
            path: "TabulaTool"
        ),
        .target(
            name: "TabulaKit",
            dependencies: ["FoundationKit"],
            path: "TabulaKit"
        ),
        .testTarget(
            name: "TabulaKitTests",
            dependencies: ["TabulaKit", "FoundationKit"]
        )
    ]
)
