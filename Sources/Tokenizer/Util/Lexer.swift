//
//  Lexer.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/29/17.
//
//

import Foundation

struct Lexer {
    enum Token {
        case identifier(String)
        case number(Float)
        case parensOpen
        case parensClose
        case assignment
        case operatorToken(String)
        case colon
        case semicolon
        case period
        case at
        case other(String)
        case whitespace(String)
    }
}

extension Lexer.Token: Equatable {
    static func ==(lhs: Lexer.Token, rhs: Lexer.Token) -> Bool {
        switch (lhs, rhs) {
        case (.identifier(let lhsIdentifier), .identifier(let rhsIdentifier)):
            return lhsIdentifier == rhsIdentifier
        case (.number(let lhsNumber), .number(let rhsNumber)):
            return lhsNumber == rhsNumber
        case (.parensOpen, .parensOpen), (.parensClose, .parensClose), (.colon, .colon), (.semicolon, .semicolon),
             (.period, .period), (.assignment, .assignment), (.at, .at):
            return true
        case (.operatorToken(let lhsOperator), .operatorToken(let rhsOperator)):
            return lhsOperator == rhsOperator
        case (.other(let lhsOther), .other(let rhsOther)):
            return lhsOther == rhsOther
        case (.whitespace(let lhsWhitespace), .whitespace(let rhsWhitespace)):
            return lhsWhitespace == rhsWhitespace
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
        ("-?[0-9]+(\\.[0-9]+)?", { Float($0).map(Token.number) }),
        ("\\(", { _ in .parensOpen }),
        ("\\)", { _ in .parensClose }),
        (":", { _ in .colon }),
        (";", { _ in .semicolon }),
        ("\\.", { _ in .period }),
        ("@", { _ in .at }),
        ("[<=>][=]", { .operatorToken($0) }),
        ("=", { _ in .assignment }),
        ]

    static func tokenize(input: String, keepWhitespace: Bool = false) -> [Token] {
        var tokens = [] as [Token]
        var content = input

        while content.characters.count > 0 {
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
                    content = content.substring(from:
                        content.index(content.startIndex, offsetBy: match.characters.count))
                    matched = true
                    break
                }
            }

            if !matched {
                let index = content.index(after: content.startIndex)
                tokens.append(.other(content.substring(to: index)))
                content = content.substring(from: index)
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
