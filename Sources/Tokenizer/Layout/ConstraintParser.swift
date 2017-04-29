//
//  ConstraintParser.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/29/17.
//
//

class ConstraintParser {
    enum ParseError: Error {
        case unexpectedToken(Lexer.Token)
        case message(String)
    }

    private let tokens: [Lexer.Token]
    private let layoutAttributes: [LayoutAttribute]
    private var position: Int = 0

    init(tokens: [Lexer.Token], layoutAttributes: [LayoutAttribute]) {
        self.tokens = tokens
        self.layoutAttributes = layoutAttributes
    }

    func parse() throws -> [Constraint] {
        return try layoutAttributes.flatMap(parse)
    }

    private func parse(for attribute: LayoutAttribute) throws -> [Constraint] {
        // Reset
        defer { position = 0 }

        var constraints: [Constraint] = []
        while !hasEnded() {
            let currentPosition = position

            let constraint = try parseConstraint(for: attribute)
            constraints.append(constraint)

            if let token = peekToken(), currentPosition == position {
                throw ParseError.unexpectedToken(token)
            }
        }
        return constraints
    }

    private func parseConstraint(for attribute: LayoutAttribute) throws -> Constraint {
        let field = parseField()

        let relation = try parseRelation() ?? .equal

        let type: ConstraintType
        if case .number(let constant)? = peekToken() {
            type = .constant(constant)
            popToken()
        } else {
            let target = parseTarget()
            let targetAnchor = try parseTargetAnchor()

            var multiplier = 1 as Float
            var constant = 0 as Float
            while !constraintEnd(), let modifier = try parseModifier() {
                switch modifier {
                case .multiplied(let by):
                    multiplier *= by
                case .divided(let by):
                    multiplier /= by
                case .offset(let by):
                    constant += by
                case .inset(let by):
                    constant += by * attribute.insetDirection
                }
            }

            type = .targeted(target: target ?? (targetAnchor != nil ? .this : .parent),
                             targetAnchor: targetAnchor ?? attribute.targetAnchor,
                             multiplier: multiplier,
                             constant: constant)
        }

        let priority = try parsePriority() ?? .required

        return Constraint(field: field, anchor: attribute.anchor, type: type, relation: relation, priority: priority)
    }

    private func hasEnded() -> Bool {
        return peekToken() == nil
    }

    private func constraintEnd() -> Bool {
        if hasEnded() {
            return true
        } else if peekToken() == .semicolon {
            popToken()
            return true
        } else {
            return false
        }
    }

    private func parseField() -> String? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() == .assignment else { return nil }

        popTokens(2)
        return identifier
    }

    private func parseRelation() throws -> ConstraintRelation? {
        guard case .operatorToken(let op)? = peekToken() else { return nil }
        popToken()

        return try ConstraintRelation(op)
    }

    private func parseTarget() -> ConstraintTarget? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() != .parensOpen else { return nil }
        popToken()
        if peekToken() == .colon, case .identifier(let layoutId)? = peekNextToken() {
            popTokens(2)
            // FIXME Add `enum Target { field(String); layoutId(String) }` and return .layoutId here
            return .layoutId(layoutId)
        } else if identifier == "super" {
            return .parent
        } else if identifier == "self" {
            return .this
        } else {
            return .field(identifier)
        }
    }

    private func parseTargetAnchor() throws -> LayoutAnchor? {
        guard peekToken() == .period, case .identifier(let identifier)? = peekNextToken() else { return nil }
        popTokens(2)
        return try LayoutAnchor(identifier)
    }

    private func parseModifier() throws -> ConstraintModifier? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() == .parensOpen else { return nil }
        popTokens(2)

        if case .identifier("by")? = peekToken(), peekNextToken() == .colon {
            popTokens(2)
        }

        guard case .number(let number)? = peekToken(), .parensClose == peekNextToken() else {
            throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
        }
        popTokens(2)

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
        if case .number(let number)? = peekNextToken() {
            popTokens(2)
            return ConstraintPriority.custom(number)
        } else if case .identifier(let identifier)? = peekNextToken() {
            popTokens(2)
            return try ConstraintPriority(identifier)
        } else {
            throw ParseError.message("Missing priority value! `@` token followed by \(peekNextToken().map(String.init(describing:)) ?? "none")")
        }
    }

    private func peekToken() -> Lexer.Token? {
        guard position < tokens.count else { return nil }
        return tokens[position]
    }

    private func peekNextToken() -> Lexer.Token? {
        guard position < tokens.count - 1 else { return nil }
        return tokens[position + 1]
    }

    private func peek<T>(_ count: Int = 1, _ f: () throws -> T?) rethrows -> T? {
        guard position + count < tokens.count else { return nil }
        position += count
        defer { position -= count }
        return try f()
    }
    
    private func popTokens(_ count: Int) {
        position += count
    }
    
    private func popToken() {
        position += 1
    }
}
