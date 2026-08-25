// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "MyChatAppBackend",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/chaqmoq/chaqmoq.git", branch: "master"),
        .package(url: "https://github.com/chaqmoq/bcrypt.git", branch: "master"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0")
    ],
    targets: [
        .executableTarget(
            name: "MyChatAppBackend",
            dependencies: [
                .product(name: "Chaqmoq", package: "chaqmoq"),
                .product(name: "BCrypt", package: "bcrypt"),
                .product(name: "Crypto", package: "swift-crypto")
            ]
        )
    ]
)
