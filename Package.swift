// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftNES",
    platforms: [.macOS("11.0")],
    dependencies: [
      .package(url: "https://github.com/ctreffs/SwiftSDL2.git", from: "1.4.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
          name: "SwiftNES",
        dependencies: [
          .product(name: "SDL", package: "SwiftSDL2")
        ]),
        .testTarget(name: "SwiftNESTests", dependencies: ["SwiftNES"])
    ]
)
