import Generator
import Tokenizer
import Foundation
import XcodeProj
import SwiftCLI

let generateCommand = GenerateCommand()
let xsdCommand = XSDCommand()

let cli = CLI(name: "generator",
              version: "0.4.0",
              description: "Command line tool used to generate Swift UI code from XML UI\nAdd `-h` after a command to see all its options.",
              commands: [generateCommand, xsdCommand])

cli.goAndExit()
