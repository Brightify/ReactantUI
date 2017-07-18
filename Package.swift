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
    dependencies: [
        //.Package(url: "https://github.com/Carthage/Commandant.git", versions: Version(0, 11, 3)..<Version(0, 11, .max)),
        //.Package(url: "https://github.com/jpsim/SourceKitten.git", versions: Version(0, 15, 0)..<Version(0, 17, .max)),
    ],
    exclude: [
        "Sources/Live",
    ]
)
