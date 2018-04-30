//
//  ConstraintParser.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/29/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

class ConstraintParser: BaseParser<Constraint> {
    private let layoutAttribute: LayoutAttribute
    
    init(tokens: [Lexer.Token], layoutAttribute: LayoutAttribute) {
        self.layoutAttribute = layoutAttribute
        super.init(tokens: tokens)
    }
    
    override func parseSingle() throws -> Constraint {
        let condition = try parseCondition()

        let field = try parseField()
        
        let relation = try parseRelation() ?? .equal
        
        let type: ConstraintType
        if case .number(let constant, _)? = peekToken() {
            type = .constant(constant)
            try popToken()
        } else {
            let target = try parseTarget()
            let targetAnchor = try parseTargetAnchor()
            
            var multiplier = 1 as Float
            var constant = 0 as Float
            while try !constraintEnd(), let modifier = try parseModifier() {
                switch modifier {
                case .multiplied(let by):
                    multiplier *= by
                case .divided(let by):
                    multiplier /= by
                case .offset(let by):
                    constant += by
                case .inset(let by):
                    constant += by * layoutAttribute.insetDirection
                }
            }
            
            type = .targeted(target: target ?? (targetAnchor != nil ? .this : .parent),
                             targetAnchor: targetAnchor ?? layoutAttribute.targetAnchor,
                             multiplier: multiplier,
                             constant: constant)
        }
        
        let priority: ConstraintPriority
        if peekToken() != .semicolon {
            priority = try parsePriority() ?? .required
        } else {
            priority = .required
            try popToken()
        }
        
        return Constraint(field: field, condition: condition, attribute: layoutAttribute, type: type, relation: relation, priority: priority)
    }
    
    private func constraintEnd() throws -> Bool {
        if hasEnded() {
            return true
        } else if peekToken() == .semicolon {
            return true
        } else {
            return false
        }
    }

    private func parseCondition() throws -> ConstraintCondition? {
        guard case .bracketsOpen? = peekToken() else { return nil }
        try popToken()

        let (tokens, numberOfAddedBrackets) = try conditionWithBrackets(tokens: tokensLeft)
        var position = 0
        let condition = try parseConditions(tokens: tokens, position: &position)

        try popTokens(position - numberOfAddedBrackets)

        try popToken()

        return condition
    }

    private func conditionWithBrackets(tokens: [Lexer.Token]) throws -> ([Lexer.Token], Int) {
        var condition: [Lexer.Token] = []
        var numberOfAddedBrackets = 0
        var position = 0

        while true {
            let token = try popToken(tokens: tokens, position: &position)

            if case .bracketsClose = token {
                break
            }

            switch token {
            case .logicalAnd, .logicalOr, .exclamation, .parensOpen, .parensClose, .equals:
                condition.append(token)
            case .identifier:
                condition += [.parensOpen, token]
                numberOfAddedBrackets += 1
                if case .equals? = peekToken(tokens: tokens, position: position) {
                    condition.append(try popToken(tokens: tokens, position: &position))

                    let token = try popToken(tokens: tokens, position: &position)
                    guard case .identifier = token else {
                        throw ParseError.message("Condition couldn't be parsed!")
                    }
                    condition.append(token)

                    if case .equals? = peekToken(tokens: tokens, position: position) {
                        condition.append(try popToken(tokens: tokens, position: &position))

                        let token = try popToken(tokens: tokens, position: &position)
                        guard case .identifier = token else {
                            throw ParseError.message("Condition couldn't be parsed!")
                        }
                        condition.append(token)
                    }
                }
                condition.append(.parensClose)
                numberOfAddedBrackets += 1
            default:
                throw ParseError.message("Condition couldn't be parsed!")
            }
        }

        numberOfAddedBrackets += try addBracketsForOperatorPrecedence(tokens: &condition)

        return (condition, numberOfAddedBrackets)
    }

    private func addBracketsForOperatorPrecedence(tokens: inout [Lexer.Token]) throws -> Int {
        var numberOfAddedBrackets = 0

        for (index, token) in tokens.enumerated() {
            if case .logicalAnd = token {
                var foo = 0
                for i in 1..<tokens.count {
                    var idx = index - i + numberOfAddedBrackets
                    if case .parensClose = tokens[idx] {
                        foo += 1
                    }

                    if case .parensOpen = tokens[idx] {
                        foo -= 1

                        if foo <= 0 {
                            if idx > 0, case .exclamation = tokens[idx - 1] {
                                idx -= 1
                            }
                            tokens.insert(.parensOpen, at: idx)
                            numberOfAddedBrackets += 1
                            break
                        }
                    }
                }

                foo = 0

                for i in 1..<tokens.count {
                    let idx = index + i + numberOfAddedBrackets
                    if case .parensOpen = tokens[idx] {
                        foo += 1
                    }

                    if case .parensClose = tokens[idx] {
                        foo -= 1

                        if foo <= 0 {
                            tokens.insert(.parensClose, at: idx)
                            numberOfAddedBrackets += 1
                            break
                        }
                    }
                }
            }
        }

        return numberOfAddedBrackets
    }

    private func parseConditions(tokens: [Lexer.Token], position: inout Int, negateNext: Bool = false) throws -> ConstraintCondition {
        var condition: ConstraintCondition
        if case .identifier? = peekToken(tokens: tokens, position: position) {
            condition = ConstraintCondition.statement(try parseSingleConditionStatement(tokens: tokens, position: &position))
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
            return ConstraintCondition.conjunction(condition, try parseConditions(tokens: tokens, position: &position))
        } else if case .logicalOr? = peekToken(tokens: tokens, position: position) {
            try popToken(tokens: tokens, position: &position)
            return ConstraintCondition.disjunction(condition, try parseConditions(tokens: tokens, position: &position))
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
    
    private func parseField() throws -> String? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() == .assignment else { return nil }
        
        try popTokens(2)
        return identifier
    }
    
    private func parseRelation() throws -> ConstraintRelation? {
        guard case .colon? = peekToken(), case .identifier(let identifier)? = peekNextToken() else { return nil }
        try popTokens(2)
        
        return try ConstraintRelation(identifier)
    }
    
    private func parseTarget() throws -> ConstraintTarget? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() != .parensOpen else { return nil }
        try popToken()
        if peekToken() == .colon, case .identifier(let layoutId)? = peekNextToken() {
            try popTokens(2)
            return .layoutId(layoutId)
        } else if identifier == "super" {
            return .parent
        } else if identifier == "self" {
            return .this
        } else if identifier == "safeAreaLayoutGuide" {
            return .safeAreaLayoutGuide
        } else {
            return .field(identifier)
        }
    }
    
    private func parseTargetAnchor() throws -> LayoutAnchor? {
        guard peekToken() == .period, case .identifier(let identifier)? = peekNextToken() else { return nil }
        try popTokens(2)
        return try LayoutAnchor(identifier)
    }
    
    private func parseModifier() throws -> ConstraintModifier? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() == .parensOpen else { return nil }
        try popTokens(2)
        
        if case .identifier("by")? = peekToken(), peekNextToken() == .colon {
            try popTokens(2)
        }
        
        guard case .number(let number, _)? = peekToken(), .parensClose == peekNextToken() else {
            throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
        }
        try popTokens(2)
        
        switch identifier {
        case "multiplied":
            return .multiplied(by: number)
        case "divided":
            return .divided(by: number)
        case "offset":
            return .offset(by: number)
        case "inset":
            return .inset(by: number)
        default:
            throw ParseError.message("Unknown modifier `\(identifier)`")
        }
    }
    
    private func parsePriority() throws -> ConstraintPriority? {
        guard case .at? = peekToken() else { return nil }
        if case .number(let number, _)? = peekNextToken() {
            try popTokens(2)
            return ConstraintPriority.custom(number)
        } else if case .identifier(let identifier)? = peekNextToken() {
            try popTokens(2)
            return try ConstraintPriority(identifier)
        } else {
            throw ParseError.message("Missing priority value! `@` token followed by \(peekNextToken().map(String.init(describing:)) ?? "none")")
        }
    }
}
