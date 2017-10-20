// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "ReactantUI",
    targets: [
        Target(name: "Tokenizer", dependencies: []),
        Target(name: "Generator", dependencies: [
            .Target(name: "Tokenizer")
        ]),

        Target(name: "reactant-ui", dependencies: [
            .Target(name: "Generator")
        ]),
    ],
    dependencies: [],
    exclude: [
        "Sources/Live",
    ]
)
