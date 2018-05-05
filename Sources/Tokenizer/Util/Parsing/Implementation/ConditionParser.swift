//
//  ConditionParser.swift
//  Example
//
//  Created by Robin Krenecky on 30/04/2018.
//

import Foundation

extension ConditionBinaryOperation {
    fileprivate static func parse(token: Lexer.Token) -> ConditionBinaryOperation? {
        switch token {
        case .logicalAnd:
            return .and
        case .logicalOr:
            return .or
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
// COMPARISON := FACTOR [ ( == | != ) FACTOR ]
// FACTOR := [ '!' ] ( '(' EXPRESSION ')' | IDENTIFIER )
// IDENTIFIER := { all cases in the ConditionStatement enum }
class ConditionParser: BaseParser<Condition> {
    override func parseSingle() throws -> Condition {
        return try parseExpression()
    }

    private func parseExpression() throws -> Condition {
        var resultCondition = try parseTerm()
        while let token = peekToken(),
            let operation = ConditionBinaryOperation.parse(token: token),
            case .or = operation {

            try popToken()
            resultCondition = .binary(operation, resultCondition, try parseTerm())
        }

        return resultCondition
    }

    private func parseTerm() throws -> Condition {
        var resultCondition = try parseComparison()
        while let token = peekToken(),
            let operation = ConditionBinaryOperation.parse(token: token),
            case .and = operation {

            try popToken()
            resultCondition = .binary(operation, resultCondition, try parseComparison())
        }

        return resultCondition
    }

    private func parseComparison() throws -> Condition {
        var resultCondition = try parseFactor()
        while let token = peekToken(),
            case .equals(let equals, _) = token {
                
            try popToken()
            let rhsCondition = try parseFactor()
            let mergedCondition: Condition
            if case .statement(let lhsStatement) = resultCondition,
                case .statement(let rhsStatement) = rhsCondition,
                let mergedStatement = lhsStatement.mergeWithSizeClass(statement: rhsStatement) {

                mergedCondition = .statement(mergedStatement)
            } else {
                mergedCondition = .binary(.equal, resultCondition, rhsCondition)
            }

            resultCondition = equals ? mergedCondition : .unary(.negation, mergedCondition)
        }

        return resultCondition
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
            return .statement(ConditionStatement(identifier: identifier)!)
        default:
            throw ConditionError("Unknown factor: \(token)")
        }
    }
}
