// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "MyChatAppBackend",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/chaqmoq/chaqmoq.git", branch: "master")
    ],
    targets: [
        .executableTarget(
            name: "MyChatAppBackend",
            dependencies: [
                .product(name: "Chaqmoq", package: "chaqmoq")
            ]
        )
    ]
)
