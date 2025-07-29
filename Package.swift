// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTTools",
    platforms: [ 
        .iOS(.v15),  
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HTTools",
            targets: ["HTTools"]
        ),
        .library(
            name: "HTLogs", 
            targets: ["HTLogs"]
        ),
        .library(
            name: "HTNetTool", 
            targets: ["HTNetTool"]
        ),
        .library(
            name: "HTAuthCamera", 
            targets: ["HTAuthCamera"]
        ),
        .library(
            name: "HTAuthContact", 
            targets: ["HTAuthContact"]
        ),
        .library(
            name: "HTAuthLocation", 
            targets: ["HTAuthLocation"]
        ),
        .library(
            name: "HTAuthMicro", 
            targets: ["HTAuthMicro"]
        ),
        .library(
            name: "HTAuthPhotos", 
            targets: ["HTAuthPhotos"]
        ),
        .library(
            name: "HTViews", 
            targets: ["HTViews"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HTLogs",
            dependencies: ["SwiftyBeaver"],
            path: "Sources/HTLogs"
        ),
        .target(
            name: "HTNetTool",
            dependencies: [],
            path: "Sources/HTNetTool"
        ),
        .target(
            name: "HTTools",
            dependencies: ["HTLogs"],
            path: "Sources/HTTools"
        ),
        .target(
            name: "HTAuthCamera",
            dependencies: [],
            path: "Sources/HTAuthCamera"
        ),
        .target(
            name: "HTAuthContact",
            dependencies: ["HTLogs"],
            path: "Sources/HTAuthContact"
        ),
        .target(
            name: "HTAuthLocation",
            dependencies: [],
            path: "Sources/HTAuthLocation"
        ),
        .target(
            name: "HTAuthMicro",
            dependencies: [],
            path: "Sources/HTAuthMicro"
        ),
        .target(
            name: "HTAuthPhotos",
            dependencies: ["HTLogs"],
            path: "Sources/HTAuthPhotos"
        ),
        .target(
            name: "HTViews",
            dependencies: ["HTLogs"],
            path: "Sources/HTViews"
        ),
        .testTarget(
            name: "HTToolsTests",
            dependencies: ["HTTools"]
        ),
    ]
)
