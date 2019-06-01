//
//  FontParser.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

class FontParser: BaseParser<Font> {
    override func parseSingle() throws -> Font {
        if case .colon? = peekToken() {
            try popToken()
            let possibleWeightToken = try popToken()
            guard case .identifier(let possibleWeight) = possibleWeightToken else {
                throw ParseError.message("Unexpected token `\(possibleWeightToken)`, expected weight identifier")
            }
            guard let weight = SystemFontWeight(rawValue: possibleWeight) else {
                throw ParseError.message("Unknown weight name `\(possibleWeight)`!")
            }
            let size: Double
            if case .at? = try? popToken() {
                let possibleSize = try popToken()
                guard case .number(let fontSize, _) = possibleSize else {
                    throw ParseError.message("Unexpected token `\(possibleSize)`, expected font size float")
                }
                size = fontSize
            } else {
                // Default
                size = 15
            }
            return .system(weight: weight, size: size)
        } else if case .number(let size, _)? = peekToken() {
            try popToken()
            return .system(weight: .regular, size: size)
        } else {
            var components = [] as [String]
            while let token = peekToken() {
                guard token != .at else { break }

                try popToken()
                switch token {
                case .identifier(let identifier):
                    components.append(identifier)
                case .number(let number):
                    components.append("\(number)")
                case .parensOpen:
                    components.append("(")
                case .parensClose:
                    components.append(")")
                case .assignment:
                    components.append("=")
                case .equals(_, let original):
                    components.append(original)
                case .colon:
                    components.append(":")
                case .semicolon:
                    components.append(";")
                case .period:
                    components.append(".")
                case .at:
                    break
                case .comma:
                    break
                case .other(let other):
                    components.append(other)
                case .whitespace(let whitespace):
                    components.append(whitespace)
                case .bracketsOpen:
                    components.append("[")
                case .bracketsClose:
                    components.append("]")
                case .exclamation:
                    components.append("!")
                case .dollar:
                    components.append("$")
                case .argument(let original):
                    components.append("\\(\(original))")
                }
            }
            let size: Double
            if case .at? = try? popToken() {
                let possibleSize = try popToken()
                guard case .number(let fontSize, _) = possibleSize else {
                    throw ParseError.message("Unexpected token `\(possibleSize)`, expected font size float")
                }
                size = fontSize
            } else {
                // Default
                size = 15
            }
            return .named(components.joined(), size: size)
        }
    }
}
