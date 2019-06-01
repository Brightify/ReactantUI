//
//  Lexer.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/29/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

struct Lexer {
    enum Token {
        case identifier(String)
        case number(value: Double, original: String)
        case parensOpen
        case parensClose
        case assignment
        case equals(value: Bool, original: String)
        case colon
        case semicolon
        case period
        case at
        case other(String)
        case whitespace(String)
        case comma
        case bracketsOpen
        case bracketsClose
        case exclamation
        case dollar
        case argument(String)
    }
}

extension Lexer.Token: Equatable {
    static func ==(lhs: Lexer.Token, rhs: Lexer.Token) -> Bool {
        switch (lhs, rhs) {
        case (.identifier(let lhsIdentifier), .identifier(let rhsIdentifier)):
            return lhsIdentifier == rhsIdentifier
        case (.number(let lhsNumber, let lhsOriginal), .number(let rhsNumber, let rhsOriginal)):
            return lhsNumber == rhsNumber && lhsOriginal == rhsOriginal
        case (.parensOpen, .parensOpen), (.parensClose, .parensClose), (.colon, .colon), (.semicolon, .semicolon),
             (.period, .period), (.assignment, .assignment), (.at, .at), (.comma, .comma), (.exclamation, .exclamation),
             (.bracketsOpen, .bracketsOpen), (.bracketsClose, .bracketsClose), (.dollar, .dollar):
            return true
        case (.equals(let lhsBool), .equals(let rhsBool)):
            return lhsBool == rhsBool
        case (.other(let lhsOther), .other(let rhsOther)):
            return lhsOther == rhsOther
        case (.whitespace(let lhsWhitespace), .whitespace(let rhsWhitespace)):
            return lhsWhitespace == rhsWhitespace
        case (.argument(let lhsArgument), .argument(let rhsArgument)):
            return lhsArgument == rhsArgument
        default:
            return false
        }
    }
}

extension Lexer {
    typealias TokenGenerator = (String) -> Token?
    static let tokenList: [(String, TokenGenerator)] = [
        ("[ \t\n]", { .whitespace($0) }),
        ("[a-zA-Z][a-zA-Z0-9]*", { .identifier($0) }),
        ("-?[0-9]+(\\.[0-9]+)?", { original in Double(original).map { Token.number(value: $0, original: original) } }),
        ("\\(", { _ in .parensOpen }),
        ("\\)", { _ in .parensClose }),
        ("\\[", { _ in .bracketsOpen }),
        ("]", { _ in .bracketsClose }),
        (":", { _ in .colon }),
        (";", { _ in .semicolon }),
        ("\\.", { _ in .period }),
        ("@", { _ in .at }),
        ("[!=][=]", { .equals(value: Bool(equalityOperator: $0), original: $0) }),
        ("=", { _ in .assignment }),
        (",", { _ in .comma }),
        ("!", { _ in .exclamation }),
        ("\\$", { _ in .dollar }),
        ("\\{\\{[a-zA-Z_][a-zA-Z_0-9]*\\}\\}", { argument in .argument(argument.argumentWithoutBrackets)})
    ]

    static func tokenize(input: String, keepWhitespace: Bool = false) -> [Token] {
        var tokens = [] as [Token]
        var content = input

        while content.count > 0 {
            var matched = false
            for (pattern, generator) in tokenList {
                if let match = content.match(regex: pattern) {
                    if let token = generator(match) {
                        if case .whitespace = token, !keepWhitespace {
                            // Ignoring
                        } else {
                            tokens.append(token)
                        }
                    }
                    content = String(content[content.index(content.startIndex, offsetBy: match.count)...])
                    matched = true
                    break
                }
            }

            if !matched {
                let index = content.index(after: content.startIndex)
                tokens.append(.other(String(content[..<index])))
                content = String(content[index...])
            }
        }
        
        return tokens
    }
}

private var expressions = [String: NSRegularExpression]()
fileprivate extension String {
    func match(regex: String) -> String? {
        let expression: NSRegularExpression
        if let exists = expressions[regex] {
            expression = exists
        } else {
            expression = try! NSRegularExpression(pattern: "^\(regex)", options: [])
            expressions[regex] = expression
        }

        let range = expression.rangeOfFirstMatch(in: self, options: [], range: NSMakeRange(0, self.utf16.count))
        if range.location != NSNotFound {
            return (self as NSString).substring(with: range)
        }
        return nil
    }
}

private extension Bool {
    init(equalityOperator: String) {
        guard equalityOperator == "==" || equalityOperator == "!=" else {
            fatalError("Wrong equality operator!")
        }

        self = equalityOperator == "=="
    }
}

private extension String {
    var argumentWithoutBrackets: String {
        var copy = self
        copy.removeFirst(2)
        copy.removeLast(2)
        return copy
    }
}
