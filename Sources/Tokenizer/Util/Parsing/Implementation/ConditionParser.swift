//
//  ConditionParser.swift
//  Example
//
//  Created by Robin Krenecky on 30/04/2018.
//

import Foundation

class ConditionParser: BaseParser<(condition: Condition, tokensToPop: Int)> {
    override func parseSingle() throws -> (Condition, Int) {
        let (tokens, numberOfAddedBrackets) = try conditionWithBrackets(tokens: remainingTokens)
        var position = 0
        let condition = try parseConditions(tokens: tokens, position: &position)

        let tokensToPop = position - numberOfAddedBrackets
        guard tokensToPop >= 0 else {
            throw ParseError.message("Condition couldn't be parsed!")
        }

        return (condition, tokensToPop + 1)
    }

    private func parseConditions(tokens: [Lexer.Token], position: inout Int, negateNext: Bool = false) throws -> Condition {
        var condition: Condition
        if case .identifier? = peekToken(tokens: tokens, position: position) {
            condition = Condition.statement(try parseSingleConditionStatement(tokens: tokens, position: &position))
        } else if case .exclamation? = peekToken(tokens: tokens, position: position) {
            try popToken(tokens: tokens, position: &position)

            return try parseConditions(tokens: tokens, position: &position, negateNext: true)
        } else if case .parensOpen? = peekToken(tokens: tokens, position: position) {
            try popToken(tokens: tokens, position: &position)

            var newPosition = 0
            condition = try parseConditions(tokens: try expressionInParenthesis(tokens: tokens, position: &position), position: &newPosition)

            if negateNext {
                condition = condition.negation
            }
        } else {
            throw ParseError.message("Condition couldn't be parsed!")
        }

        if case .logicalAnd? = peekToken(tokens: tokens, position: position) {
            try popToken(tokens: tokens, position: &position)
            return Condition.conjunction(condition, try parseConditions(tokens: tokens, position: &position))
        } else if case .logicalOr? = peekToken(tokens: tokens, position: position) {
            try popToken(tokens: tokens, position: &position)
            return Condition.disjunction(condition, try parseConditions(tokens: tokens, position: &position))
        } else {
            return condition
        }
    }

    private func expressionInParenthesis(tokens: [Lexer.Token], position: inout Int) throws -> [Lexer.Token] {
        var condition: [Lexer.Token] = []
        var closeParensLeftToSkip = 0

        while true {
            let token = try popToken(tokens: tokens, position: &position)
            if token == .parensClose {
                if closeParensLeftToSkip == 0 {
                    break
                }

                closeParensLeftToSkip -= 1
            } else if token == .parensOpen {
                closeParensLeftToSkip += 1
            }

            condition.append(token)
        }

        return condition
    }

    private func parseSingleConditionStatement(tokens: [Lexer.Token], position: inout Int) throws  -> ConditionStatement {
        guard case .identifier(let identifier)? = peekToken(tokens: tokens, position: position) else {
            throw ParseError.message("Condition couldn't be parsed!")
        }
        try popToken(tokens: tokens, position: &position)

        if case .equals(var conditionValue, _)? = peekToken(tokens: tokens, position: position) {
            try popToken(tokens: tokens, position: &position)

            guard case .identifier(let nextValue)? = peekToken(tokens: tokens, position: position) else {
                throw ParseError.message("Condition couldn't be parsed!")
            }

            try popToken(tokens: tokens, position: &position)

            if let bool = Bool(nextValue) {
                guard let condition = ConditionStatement(identifier: identifier, conditionValue: bool == conditionValue) else {
                    throw ParseError.message("Condition couldn't be parsed!")
                }

                return condition
            } else {
                if case .equals? = peekToken(tokens: tokens, position: position),
                    case .identifier(let value)? = peekNextToken(tokens: tokens, position: position),
                    let bool = Bool(value) {
                    conditionValue = bool == conditionValue
                    try popTokens(tokens: tokens, position: &position, 2)
                }

                guard let condition = ConditionStatement(identifier: identifier, type: nextValue, conditionValue: conditionValue) else {
                    throw ParseError.message("Condition couldn't be parsed!")
                }

                return condition
            }
        } else {
            guard let condition = ConditionStatement(identifier: identifier, conditionValue: true) else {
                throw ParseError.message("Condition couldn't be parsed!")
            }

            return condition
        }
    }

    private func conditionWithBrackets(tokens: [Lexer.Token]) throws -> ([Lexer.Token], Int) {
        var condition: [Lexer.Token] = []
        var numberOfAddedBrackets = 0
        var position = 0

        var token = try popToken(tokens: tokens, position: &position)
        while token != .bracketsClose {
            switch token {
            case .logicalAnd, .logicalOr, .exclamation, .parensOpen, .parensClose, .equals:
                condition.append(token)
            case .identifier:
                condition += [.parensOpen, token]
                numberOfAddedBrackets += 1

                try addRemainingExpressionIfNeeded(tokens: tokens, position: &position, condition: &condition)

                condition.append(.parensClose)
                numberOfAddedBrackets += 1
            default:
                throw ParseError.message("Condition couldn't be parsed!")
            }

            token = try popToken(tokens: tokens, position: &position)
        }

        numberOfAddedBrackets += try addBracketsForOperatorPrecedence(condition: &condition)

        return (condition, numberOfAddedBrackets)
    }

    private func addRemainingExpressionIfNeeded(tokens: [Lexer.Token], position: inout Int, condition: inout [Lexer.Token]) throws {
        if case .equals? = peekToken(tokens: tokens, position: position) {
            condition.append(try popToken(tokens: tokens, position: &position))

            let token = try popToken(tokens: tokens, position: &position)

            guard case .identifier = token else {
                throw ParseError.message("Condition couldn't be parsed!")
            }
            condition.append(token)

            try addRemainingExpressionIfNeeded(tokens: tokens, position: &position, condition: &condition)
        }
    }

    private func addBracketsForOperatorPrecedence(condition: inout [Lexer.Token]) throws -> Int {
        var numberOfAddedBrackets = 0

        for (index, token) in condition.enumerated() where token == .logicalAnd {
            addBracketsAroundExpression(condition: &condition, numberOfAddedBrackets: &numberOfAddedBrackets, position: index)
        }

        return numberOfAddedBrackets
    }

    private func addBracketsAroundExpression(condition: inout [Lexer.Token], numberOfAddedBrackets: inout Int, position: Int) {
        var numberOfParensLeftToSkip = 0

        for i in 1..<condition.count {
            var idx = position - i + numberOfAddedBrackets
            if case .parensClose = condition[idx] {
                numberOfParensLeftToSkip += 1
            }

            if case .parensOpen = condition[idx] {
                numberOfParensLeftToSkip -= 1

                if numberOfParensLeftToSkip <= 0 {
                    if idx > 0, case .exclamation = condition[idx - 1] {
                        idx -= 1
                    }
                    condition.insert(.parensOpen, at: idx)
                    numberOfAddedBrackets += 1
                    break
                }
            }
        }

        numberOfParensLeftToSkip = 0

        for i in 1..<condition.count {
            let idx = position + i + numberOfAddedBrackets
            if case .parensOpen = condition[idx] {
                numberOfParensLeftToSkip += 1
            }

            if case .parensClose = condition[idx] {
                numberOfParensLeftToSkip -= 1

                if numberOfParensLeftToSkip <= 0 {
                    condition.insert(.parensClose, at: idx)
                    numberOfAddedBrackets += 1
                    break
                }
            }
        }
    }
}
