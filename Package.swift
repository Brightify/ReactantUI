// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "ReactantUI",
    products: [
        .executable(
            name: "reactant-ui",
            targets: ["reactant-ui"]),
        .library(
            name: "SwiftCodeGen",
            targets: ["SwiftCodeGen"]),
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
        .package(url: "https://github.com/tadija/AEXML.git", .exact("4.3.3")),
        .package(url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.2.2")
    ],
    targets: [
        .target(
            name: "SwiftCodeGen",
            dependencies: []),
        .target(
            name: "Common",
            dependencies: []),
        .target(
            name: "Tokenizer",
            dependencies: ["Common", "SwiftCodeGen"]),
        .target(
            name: "Generator",
            dependencies: ["Tokenizer", "xcodeproj", "SwiftCLI", "AEXML", "SwiftCodeGen"]),
        .target(
            name: "reactant-ui",
            dependencies: ["Tokenizer", "Generator", "SwiftCodeGen"])
    ]
)
