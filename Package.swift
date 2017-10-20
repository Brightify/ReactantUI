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
    dependencies: [],
    targets: [
        .target(
            name: "Tokenizer",
            dependencies: []),
        .target(
            name: "Generator",
            dependencies: ["Tokenizer"]),
        .target(
            name: "reactant-ui",
            dependencies: ["Tokenizer", "Generator"])
    ]
)
