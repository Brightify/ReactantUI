//
//  BaseParser.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

class BaseParser<ITEM> {
    private var tokens: [Lexer.Token]
    private var position: Int = 0

    init(tokens: [Lexer.Token]) {
        self.tokens = tokens
    }

    func parse() throws -> [ITEM] {
        // Reset
        let tokensBackup = tokens
        defer {
            tokens = tokensBackup
            position = 0
        }

        var items = [] as [ITEM]
        while !hasEnded() {
            let currentPosition = position

            let item = try parseSingle()
            items.append(item)

            if let token = peekToken(), currentPosition == position {
                throw ParseError.unexpectedToken(token)
            }
        }
        return items
    }

    func hasEnded() -> Bool {
        return peekToken() == nil
    }

    func parseSingle() throws -> ITEM {
        fatalError("Abstract!")
    }

    func peekToken() -> Lexer.Token? {
        guard position < tokens.count else { return nil }
        return tokens[position]
    }

    func peekNextToken() -> Lexer.Token? {
        guard position < tokens.count - 1 else { return nil }
        return tokens[position + 1]
    }

    func peekNext<T>(_ f: (Lexer.Token) throws -> T?) rethrows -> T? {
        guard let nextToken = peekNextToken() else { return nil }
        position += 1
        defer { position -= 1 }
        return try f(nextToken)
    }

    @discardableResult
    func popTokens(_ count: Int) throws -> [Lexer.Token] {
        guard position < tokens.count - count + 1 else {
            throw ParseError.message("Cannot advance token. Current: \(String(describing: peekToken())).")
        }
        let poppedTokens = tokens[position..<position+count]
        position += count
        return Array(poppedTokens)
    }

    @discardableResult
    func popToken() throws -> Lexer.Token {
        guard position < tokens.count else {
            throw ParseError.message("Cannot advance token. Current: \(String(describing: peekToken())).")
        }
        let token = tokens[position]
        position += 1
        return token
    }

    @discardableResult
    func popLastToken() throws -> Lexer.Token {
        guard !tokens.isEmpty else {
            throw ParseError.message("Cannot pop last token")
        }
        return tokens.removeLast()
    }
}
