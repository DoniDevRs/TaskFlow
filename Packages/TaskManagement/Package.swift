// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "TaskManagement",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TaskManagement", targets: ["TaskManagement"])
    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        .target(
            name: "TaskManagement",
            dependencies: ["Core"],
            path: "Sources/TaskManagement",
            resources: [.process("Resources/Localizable.xcstrings")]
        ),
        .testTarget(name: "TaskManagementTests", dependencies: ["TaskManagement"], path: "Tests/TaskManagementTests")
    ]
)
