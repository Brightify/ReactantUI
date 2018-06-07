//
//  BaseParser.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

class BaseParser<ITEM> {
    private var tokens: [Lexer.Token]
    private var position = 0

    var remainingTokens: [Lexer.Token] {
        return Array(tokens[position...])
    }

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
        return peekAhead(offset: 0)
    }

    func peekNextToken() -> Lexer.Token? {
        return peekAhead(offset: 1)
    }

//    func peekNext<T>(tokens: [Lexer.Token], position: inout Int, _ f: (Lexer.Token) throws -> T?) rethrows -> T? {
//        guard let nextToken = peekNextToken(tokens: tokens, position: position) else { return nil }
//        position += 1
//        defer { position -= 1 }
//        return try f(nextToken)
//    }
//
//    func peekNext<T>(_ f: (Lexer.Token) throws -> T?) rethrows -> T? {
//        return try peekNext(tokens: tokens, position: &position, f)
//    }

    func peekAhead(offset: Int) -> Lexer.Token? {
        guard position + offset < tokens.count else { return nil }
        return tokens[position + offset]
    }

    @discardableResult
    func popTokens(tokens: [Lexer.Token], position: inout Int, _ count: Int) throws -> [Lexer.Token] {
        guard position < tokens.count - count + 1 else {
            throw ParseError.message("Cannot advance token. Current: \(String(describing: peekToken())).")
        }
        let poppedTokens = tokens[position..<position+count]
        position += count
        return Array(poppedTokens)
    }

    @discardableResult
    func popTokens(_ count: Int) throws -> [Lexer.Token] {
        return try popTokens(tokens: tokens, position: &position, count)
    }

    @discardableResult
    func popToken(tokens: [Lexer.Token], position: inout Int) throws -> Lexer.Token {
        guard position < tokens.count else {
            throw ParseError.message("Cannot advance token. Current: \(String(describing: peekToken())).")
        }
        let token = tokens[position]
        position += 1
        return token
    }

    @discardableResult
    func popToken() throws -> Lexer.Token {
        return try popToken(tokens: tokens, position: &position)
    }

    @discardableResult
    func popLastToken(tokens: inout [Lexer.Token]) throws -> Lexer.Token {
        guard !tokens.isEmpty else {
            throw ParseError.message("Cannot pop last token")
        }
        return tokens.removeLast()
    }

    @discardableResult
    func popLastToken() throws -> Lexer.Token {
        return try popLastToken(tokens: &tokens)
    }

    func matchToken(_ token: Lexer.Token?) throws -> Bool {
        let areEqual = peekToken() == token
        if areEqual {
            try popToken()
        }
        return areEqual
    }
}
