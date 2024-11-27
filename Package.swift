// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DucascopyDataProvider",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DucascopyDataProvider",
            targets: ["DucascopyDataProvider"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vitali-kurlovich/DataProvider", from: "1.0.0"),
        .package(url: "https://github.com/vitali-kurlovich/DukascopyDecoder", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        //
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DucascopyDataProvider",
            dependencies: [
                "DataProvider",
            ]
        ),
        .testTarget(
            name: "DucascopyDataProviderTests",
            dependencies: ["DucascopyDataProvider"]
        ),
    ]
)
