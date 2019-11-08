// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "ReactantUI",
    products: [
        .executable(
            name: "reactant-ui",
            targets: ["reactant-ui"]),
        .library(
            name: "Common",
            targets: ["Common"]),
        .library(
            name: "Tokenizer",
            targets: ["Tokenizer"]),
        .library(
            name: "Generator",
            targets: ["Generator"])
    ],
    dependencies: [
        .package(url: "https://github.com/tadija/AEXML.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/tuist/XcodeProj.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.3.3")
    ],
    targets: [
        .target(
            name: "Common",
            dependencies: []),
        .target(
            name: "Tokenizer",
            dependencies: ["Common"]),
        .target(
            name: "Generator",
            dependencies: ["Tokenizer", "XcodeProj", "SwiftCLI", "AEXML"]),
        .target(
            name: "reactant-ui",
            dependencies: ["Tokenizer", "Generator"])
    ]
)
