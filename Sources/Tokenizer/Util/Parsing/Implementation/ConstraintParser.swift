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

        let condition = try parseConditions()

        guard case .bracketsClose? = peekToken() else {
            throw ParseError.message("Condition couldn't be parsed!")
        }
        try popToken()

        return condition
    }

    private func parseConditions(isNegation: Bool = false, inParenthesis: Bool = false) throws -> ConstraintCondition {
        var statement: ConditionStatement
        if case .identifier? = peekToken() {
            statement = try parseSingleConditionStatement(isNegation: isNegation)
        } else if case .exclamation? = peekToken() {
            try popToken()
            return try parseConditions(isNegation: true)
        } else if case .parensOpen? = peekToken() {
            try popToken()
            return try parseConditions(isNegation: isNegation, inParenthesis: true)
        } else {
            throw ParseError.message("Condition couldn't be parsed!")
        }

        let condition = ConstraintCondition.statement(statement)

        if case .logicalAnd? = peekToken() {
            try popToken()
            return ConstraintCondition.conjunction(condition, try parseConditions(inParenthesis: inParenthesis))
        } else if case .logicalOr? = peekToken() {
            try popToken()
            return ConstraintCondition.disjunction(condition, try parseConditions(inParenthesis: inParenthesis))
        } else if case .parensClose? = peekToken(), inParenthesis {
            try popToken()

            if case .logicalAnd? = peekToken() {
                try popToken()
                return ConstraintCondition.conjunction(condition, try parseConditions())
            } else if case .logicalOr? = peekToken() {
                try popToken()
                return ConstraintCondition.disjunction(condition, try parseConditions())
            } else {
                return condition
            }
        } else if inParenthesis {
            throw ParseError.message("Condition couldn't be parsed!")
        } else {
            return condition
        }
    }

    private func parseSingleConditionStatement(isNegation: Bool = false) throws  -> ConditionStatement {
        guard case .identifier(let identifier)? = peekToken() else {
            throw ParseError.message("Condition couldn't be parsed!")
        }
        try popToken()

        if case .equals? = peekToken() {
            try popToken()

            guard case .identifier(let nextValue)? = peekToken() else {
                throw ParseError.message("Condition couldn't be parsed!")
            }

            try popToken()

            if let bool = Bool(nextValue) {
                guard let condition = ConditionStatement(identifier: identifier, conditionValue: isNegation ? !bool : bool) else {
                    throw ParseError.message("Condition couldn't be parsed!")
                }

                return condition
            } else {
                var conditionValue = !isNegation
                if case .equals? = peekToken(), case .identifier(let value)? = peekNextToken(), let bool = Bool(value) {
                    conditionValue = isNegation ? !bool : bool
                    try popTokens(2)
                }

                guard let condition = ConditionStatement(identifier: identifier, type: nextValue, conditionValue: conditionValue) else {
                    throw ParseError.message("Condition couldn't be parsed!")
                }

                return condition
            }
        } else {
            guard let condition = ConditionStatement(identifier: identifier, conditionValue: !isNegation) else {
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
