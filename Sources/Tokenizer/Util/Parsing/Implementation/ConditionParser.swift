//
//  ConditionParser.swift
//  Example
//
//  Created by Robin Krenecky on 30/04/2018.
//

import Foundation

extension ConditionParser {
    fileprivate func toBinaryOperation(token: Lexer.Token) -> ConditionBinaryOperation? {
        switch token {
        case .identifier(let candidate) where candidate.lowercased() == "and":
            return .and
        case .identifier(let candidate) where candidate.lowercased() == "or":
            return .or
        case .colon:
            guard let nextToken = peekNextToken() else { return nil }
            switch nextToken {
            case .identifier("lt"):
                return .less
            case .identifier("gt"):
                return .greater
            case .identifier("lte"):
                return .lessEqual
            case .identifier("gte"):
                return .greaterEqual
            default:
                return nil
            }
        default:
            return nil
        }
    }
}

// this parser uses recursive descent
// each level of functions presents a precedence
// `parseExpression` takes care of the lowest priority operators
// `parseFactor` on the other hand parses the indivisible condition parts
// EBNF as of making this parser:
// CONDITION := '[' EXPRESSION ']'
// EXPRESSION := TERM [ or TERM ]
// TERM := COMPARISON [ and COMPARISON ]
// COMPARISON := FACTOR [ ( == | != | ':gt' | ':gte' | ':lt' | 'lte' ) FACTOR ]
// FACTOR := [ '!' ] ( '(' EXPRESSION ')' | IDENTIFIER | FLOAT_NUMBER )
// FLOAT_NUMBER := { same as Swift's `Float` }
// IDENTIFIER := { all cases in the ConditionStatement enum }
class ConditionParser: BaseParser<Condition> {
    override func parseSingle() throws -> Condition {
        return try parseExpression()
    }

    private func parseExpression() throws -> Condition {
        var resultCondition = try parseTerm()
        while let token = peekToken(),
            let operation = toBinaryOperation(token: token),
            case .or = operation {

            try popToken()
            resultCondition = .binary(operation, resultCondition, try parseTerm())
        }

        return resultCondition
    }

    private func parseTerm() throws -> Condition {
        var resultCondition = try parseComparison()
        while let token = peekToken(),
            let operation = toBinaryOperation(token: token),
            case .and = operation {

            try popToken()
            resultCondition = .binary(operation, resultCondition, try parseComparison())
        }

        return resultCondition
    }

    private func parseComparison() throws -> Condition {
        var resultCondition = try parseFactor()
        while let token = peekToken() {
            if case .equals(let equals, _) = token {
                try popToken()
                let rhsCondition = try parseFactor()
                let mergedCondition = try mergeComparison(lhsCondition: resultCondition, rhsCondition: rhsCondition)
                resultCondition = equals ? mergedCondition : .unary(.negation, mergedCondition)
            } else if let binaryOperation = toBinaryOperation(token: token) {
                switch binaryOperation {
                case .less, .lessEqual, .greater, .greaterEqual:
                    break
                default:
                    return resultCondition
                }
                try popTokens(2) // because of the colon and the identifier after the colon (e.g. :gt)
                let rhsCondition = try parseFactor()
                resultCondition = .binary(binaryOperation, resultCondition, rhsCondition)
            } else {
                return resultCondition
            }
        }

        return resultCondition
    }

    private func mergeComparison(lhsCondition: Condition, rhsCondition: Condition) throws -> Condition {
        let mergedCondition: Condition
        if case .statement(let lhsStatement) = lhsCondition,
            case .statement(let rhsStatement) = rhsCondition,
            let mergedStatement = lhsStatement.mergeWith(statement: rhsStatement) {

            mergedCondition = .statement(mergedStatement)
        } else {
            mergedCondition = .binary(.equal, lhsCondition, rhsCondition)
        }

        return mergedCondition
    }

    private func parseFactor() throws -> Condition {
        guard let token = peekToken() else { throw ConditionError("No tokens left to parse.") }
        switch token {
        case .exclamation:
            try popToken()
            return try parseFactor().negation
        case .parensOpen:
            try popToken()
            let parsedCondition = Condition.unary(.none, try parseExpression())
            guard try matchToken(.parensClose) else { throw ConditionError("Unmatched parenthesis occured in the condition.") }
            return parsedCondition
        case .identifier(let identifier):
            try popToken()
            guard let statement = ConditionStatement(identifier: identifier) else {
                throw ConditionError("Identifier `\(identifier)` is not valid condition statement.")
            }
            return .statement(statement)
        case .number(let number, _):
            try popToken()
            return .statement(.number(number))
        default:
            throw ConditionError("Unknown factor: \(token)")
        }
    }
}
