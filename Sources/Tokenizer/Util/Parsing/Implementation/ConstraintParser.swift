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
        // condition parsing
        var condition: Condition? = nil
        if try matchToken(.bracketsOpen) {
            var conditionTokens = [] as [Lexer.Token]
            // we're going on until `.bracketsClose` token is matched
            while !(try matchToken(.bracketsClose)) {
                let token = try popToken()
                switch token {
                case .exclamation, .parensOpen, .parensClose, .equals, .identifier, .colon, .number:
                    conditionTokens.append(token)
                default:
                    throw ParseError.message("Unknown token \(token) in condition.")
                }
            }

            condition = try ConditionParser(tokens: conditionTokens).parseSingle()
            try condition?.validate()
        }

        let field = try parseField()
        
        let relation = try parseRelation() ?? .equal
        
        let type: ConstraintType
        if case .number(let constant, _)? = peekToken() {
            type = .constant(constant)
            try popToken()
        } else {
            let target = try parseTarget()
            let targetAnchor = try parseTargetAnchor()
            
            var multiplier = 1 as Double
            var constant = 0 as Double
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
        if identifier == "super" {
            return .parent
        } else if identifier == "self" {
            return .this
        } else if identifier == "safeAreaLayoutGuide" {
            return .safeAreaLayoutGuide
        } else if identifier == "readableContentGuide" {
            return .readableContentGuide
        } else {
            return .identifier(identifier)
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
