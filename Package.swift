// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "ReactantUI",
    products: [
        .executable(
            name: "reactant-ui",
            targets: ["reactant-ui"]),
        .library(
            name: "Tokenizer",
            targets: ["Tokenizer"]),
        .library(
            name: "Generator",
            targets: ["Generator"])
    ],
    dependencies: [
        .package(url: "https://github.com/tadija/AEXML.git", .exact("4.2.2")),
        .package(url: "https://github.com/xcodeswift/xcproj.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "Tokenizer",
            dependencies: []),
        .target(
            name: "Generator",
            dependencies: ["Tokenizer", "xcproj", "SwiftCLI", "AEXML"]),
        .target(
            name: "reactant-ui",
            dependencies: ["Tokenizer", "Generator"])
    ]
)
