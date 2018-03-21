import Generator
import Tokenizer
import Foundation
import xcproj
import SwiftCLI

let generateCommand = GenerateCommand()
let xsdCommand = XSDCommand()

let cli = CLI(name: "generator",
              version: "0.3.0",
              description: "Command line tool used to generate Swift UI code from XML UI",
              commands: [generateCommand, xsdCommand])

cli.goAndExit()
