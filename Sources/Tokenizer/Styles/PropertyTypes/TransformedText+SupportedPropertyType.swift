//
//  TransformedText.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

extension TransformedText: SupportedPropertyType {
    public var generated: String {
        func resolveTransformations(text: TransformedText) -> String {
            switch text {
            case .transform(.uppercased, let inner):
                return resolveTransformations(text: inner) + ".uppercased()"
            case .transform(.lowercased, let inner):
                return resolveTransformations(text: inner) + ".lowercased()"
            case .transform(.localized, let inner):
                return "NSLocalizedString(\(resolveTransformations(text: inner)), comment: \"\")"
            case .transform(.capitalized, let inner):
                return resolveTransformations(text: inner) + ".capitalized"
            case .text(let value):
                let escapedValue = value
                    .replacingOccurrences(of: "\"", with: "\\\"")
                    .replacingOccurrences(of: "\n", with: "\\n")
                    .replacingOccurrences(of: "\r", with: "\\r")

                return "\"\(escapedValue)\""
            }
        }
        return resolveTransformations(text: self)
    }

    #if SanAndreas
    public func dematerialize() -> String {
        func resolveTransformations(text: TransformedText) -> String {
            switch text {
            case .transform(.uppercased, let inner):
                return ":uppercased(\(resolveTransformations(text: inner)))"
            case .transform(.lowercased, let inner):
                return ":lowercased(\(resolveTransformations(text: inner)))"
            case .transform(.localized, let inner):
                return ":localized(\(resolveTransformations(text: inner)))"
            case .transform(.capitalized, let inner):
                return ":capitalized(\(resolveTransformations(text: inner)))"
            case .text(let value):
                return value.replacingOccurrences(of: "\"", with: "&quot;")
                    .replacingOccurrences(of: "\n", with: "\\n")
                    .replacingOccurrences(of: "\r", with: "\\r")
            }
        }
        return resolveTransformations(text: self)
    }
    #endif

    #if ReactantRuntime
    public var runtimeValue: Any? {
        func resolveTransformations(text: TransformedText) -> String {
            switch text {
            case .transform(.uppercased, let inner):
                return resolveTransformations(text: inner).uppercased()
            case .transform(.lowercased, let inner):
                return resolveTransformations(text: inner).lowercased()
            case .transform(.localized, let inner):
                return NSLocalizedString(resolveTransformations(text: inner), comment: "")
            case .transform(.capitalized, let inner):
                return resolveTransformations(text: inner).capitalized
            case .text(let value):
                return value.replacingOccurrences(of: "\\n", with: "\n")
                    .replacingOccurrences(of: "\\r", with: "\r")
            }
        }
        return resolveTransformations(text: self)
    }
    #endif

    public static func materialize(from value: String) throws -> TransformedText {
        let tokens = Lexer.tokenize(input: value, keepWhitespace: true)
        return try TextParser(tokens: tokens).parseSingle()
    }

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}
