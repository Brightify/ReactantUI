import Generator
import Tokenizer
import Foundation
import xcproj
import SwiftCLI

let generateCommand = GenerateCommand()

let cli = CLI(name: "generator", version: "0.3.0", description: "Command line tool used to generate Swift UI code from XML UI", commands: [generateCommand])

cli.goAndExit()

enum GeneratorError: Error {
    case inavlidType
}
