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
        .package(path: "../LoggerKit"),
        .package(path: "../FoundationKit"),
        .package(path: "../CommandLineKit"),
        .package(path: "../PythonKit")
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
