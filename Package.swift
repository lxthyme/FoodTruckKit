// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FoodTruckKit",
    defaultLocalization: "en",
    platforms: [
        .macOS("13.3"),
        // .iOS(.v16),
        .iOS("16.4"),
        .macCatalyst("16.4")
    ],
    products: [
        .library(
            name: "FoodTruckKit",
            targets: ["FoodTruckKit"]
        )
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
        // .executableTarget(
            name: "FoodTruckKit",
            dependencies: [],
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
