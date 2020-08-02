// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMC",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftMC",
            targets: ["SwiftMC"]
        ),
        .executable(
            name: "SwiftMCRun",
            targets: ["SwiftMCRun"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/adam-fowler/compress-nio.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftMC",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "CompressNIO", package: "compress-nio"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ]
        ),
        .target(
            name: "SwiftMCRun",
            dependencies: ["SwiftMC"]
        ),
        .testTarget(
            name: "SwiftMCTests",
            dependencies: ["SwiftMC"]
        )
    ]
)
