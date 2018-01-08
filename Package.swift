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
        .package(url: "https://github.com/xcodeswift/xcproj.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(
            name: "Tokenizer",
            dependencies: []),
        .target(
            name: "Generator",
            dependencies: ["Tokenizer", "xcproj"]),
        .target(
            name: "reactant-ui",
            dependencies: ["Tokenizer", "Generator"])
    ]
)
