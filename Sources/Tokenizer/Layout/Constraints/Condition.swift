//
//  Condition.swift
//  Differentiator-iOS
//
//  Created by Robin Krenecky on 27/04/2018.
//

import Foundation
// canImport(Common) is required because there's no module "Common" in ReactantLiveUI
#if canImport(Common)
import Common
#endif
#if canImport(UIKit)
import UIKit
#endif

struct ConditionError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}

public enum ConditionBinaryOperation {
    case and
    case or
    case equal
    case less
    case lessEqual
    case greater
    case greaterEqual

    public var requiresLogical: Bool {
        switch self {
        case .and, .or:
            return true
        default:
            return false
        }
    }

    public var requiresComparable: Bool {
        switch self {
        case .and, .or:
            return false
        default:
            return true
        }
    }
}

public enum ConditionUnaryOperation {
    case none
    case negation
}

/**
 * Description of a condition as a binary tree where:
 * **statement** is the node itself
 * **unary** is a node with one child
 * **binary** is a node with two children
 * - TODO: Make the `ConditionStatement` generic as to allow for arbitrary uses of this enum.
 */
public indirect enum Condition {
    case statement(ConditionStatement)
    case unary(ConditionUnaryOperation, Condition)
    case binary(ConditionBinaryOperation, Condition, Condition)

    public var isComparable: Bool {
        switch self {
        case .statement(let statement):
            return statement.isComparable
        case .unary(.none, let condition):
            return condition.isComparable
        case .unary(.negation, _), .binary:
            return false
        }
    }

/// TODO Implement better validation errors
//    enum ValidationResult {
//        case valid
//        case error(Condition, String)
//        indirect case innerError(Condition, ValidationResult)
//
//        init(from innerResult: ValidationResult) {
//            switch innerResult {
//            case .valid:
//                self = .valid
//            case .error, .innerError:
//                self = .innerError(innerResult)
//            }
//        }
//    }

    func validate() throws {
        let conditionsToValidate: [Condition]
        switch self {
        case .statement:
            conditionsToValidate = []

        case .unary(.negation, let condition):
            // Negating a comparable value is invalid
            guard !condition.isComparable, case .statement = condition else {
                throw TokenizationError(message: "Negating `\(condition.generateXML())` is not valid.")
            }
            conditionsToValidate = [condition]

        case .unary(.none, let condition):
            conditionsToValidate = [condition]

        case .binary(let operation, let lhsCondition, let rhsCondition) where operation.requiresLogical:
            // Both conditions have to be logical (= not comparable)
            guard !lhsCondition.isComparable && !rhsCondition.isComparable else {
                throw TokenizationError(message: "Condition `\(lhsCondition.generateXML())` or `\(rhsCondition.generateXML())` is not logical and therefore invalid for the operation.")
            }
            conditionsToValidate = [lhsCondition, rhsCondition]

        case .binary(let operation, let lhsCondition, let rhsCondition) where operation.requiresComparable:
            // Both conditions have to be comparable when using a comparable operation
            guard lhsCondition.isComparable && rhsCondition.isComparable else {
                throw TokenizationError(message: "Condition `\(lhsCondition.generateXML())` or `\(rhsCondition.generateXML())` is not comparable and therefore invalid for the operation.")
            }
            conditionsToValidate = [lhsCondition, rhsCondition]

        case .binary(_, let lhsCondition, let rhsCondition):
            conditionsToValidate = [lhsCondition, rhsCondition]
        }

        // Ensure all conditions are valid
        try conditionsToValidate.forEach { try $0.validate() }
    }

    var negation: Condition {
        switch self {
        case .statement(let statement):
            return .unary(.negation, .statement(statement))
        case .unary(let operation, let condition):
            return .unary(operation == .none ? .negation : .none, condition)
        case .binary:
            return .unary(.negation, self)
        }
    }

    #if canImport(UIKit)
    func evaluate(from traits: UITraitHelper, in view: UIView) throws -> Bool {
        switch self {
        case .statement(let statement):
            return try statement.evaluate(from: traits)
        case .unary(let operation, let condition):
            return try condition.evaluate(from: traits, in: view) == (operation != .negation)
        case .binary(let operation, let lhsCondition, let rhsCondition):
            switch operation {
            case .and:
                return try lhsCondition.evaluate(from: traits, in: view) && rhsCondition.evaluate(from: traits, in: view)
            case .or:
                return try lhsCondition.evaluate(from: traits, in: view) || rhsCondition.evaluate(from: traits, in: view)
            case .equal where lhsCondition.isComparable && rhsCondition.isComparable:
                return try compare(from: traits, in: view)
            case .equal where !lhsCondition.isComparable && !rhsCondition.isComparable:
                return try lhsCondition.evaluate(from: traits, in: view) == rhsCondition.evaluate(from: traits, in: view)
            case .equal:
                throw ConditionError("Can't chech equality ")
            case .less, .lessEqual, .greater, .greaterEqual:
                return try compare(from: traits, in: view)
            }
        }
    }

    func compare(from traits: UITraitHelper, in view: UIView) throws -> Bool {
        guard case .binary(let operation, let lhsCondition, let rhsCondition) = self else {
            fatalError("Comparation evaluation somehow got called with a nonbinary condition.")
        }
        guard case .statement(let lhsStatement) = lhsCondition, case .statement(let rhsStatement) = rhsCondition else {
            throw ConditionError("Cannot evaluate comparison from two conditions, please compare only two factors (don't use parentheses).")
        }
        let lhsValue = lhsStatement.numberValue(from: traits)
        let rhsValue = rhsStatement.numberValue(from: traits)
        switch operation {
        case .less:
            return lhsValue < rhsValue
        case .lessEqual:
            return lhsValue <= rhsValue
        case .greater:
            return lhsValue > rhsValue
        case .greaterEqual:
            return lhsValue >= rhsValue
        default:
            return false
        }
    }
    #endif

    static var alwaysTrue: Condition {
        return .statement(.trueStatement)
    }

    static var alwaysFalse: Condition {
        return alwaysTrue.negation
    }
}

// MARK:- Generator Extensions
#if canImport(SwiftCodeGen)
import SwiftCodeGen

extension Condition {
    public func generateSwift(viewName: String) -> Expression {
        switch self {
        case .statement(let statement):
            return .constant(statement.generateSwift(viewName: viewName))
        case .unary(let operation, let condition):
            return .constant("\(operation.swiftRepresentation)\(condition.generateSwift(viewName: viewName))")
        case .binary(let operation, let lhsCondition, let rhsCondition):
            return .operator(
                lhs: lhsCondition.generateSwift(viewName: viewName),
                operator: operation.swiftRepresentation,
                rhs: rhsCondition.generateSwift(viewName: viewName))
        }
    }
}
#endif

extension Condition {
    // MARK: - XML condition generators
    public func generateXML() -> String {
        switch self {
        case .statement(let statement):
            return statement.generateXML()
        case .unary(let operation, let condition):
            return "\(operation.xmlRepresentation)\(condition.generateXML())"
        case .binary(let operation, let lhsCondition, let rhsCondition):
            return [
                lhsCondition.generateXML(),
                operation.xmlRepresentation,
                rhsCondition.generateXML(),
            ].joined(separator: " ")
        }
    }
}

extension ConditionBinaryOperation {
    var swiftRepresentation: String {
        switch self {
        case .equal:
            return "=="
        case .and:
            return "&&"
        case .or:
            return "||"
        case .less:
            return "<"
        case .lessEqual:
            return "<="
        case .greater:
            return ">"
        case .greaterEqual:
            return ">="
        }
    }

    var xmlRepresentation: String {
        switch self {
        case .equal:
            return swiftRepresentation
        case .and:
            return "and"
        case .or:
            return "or"
        case .less:
            return ":lt"
        case .lessEqual:
            return ":lte"
        case .greater:
            return ":gt"
        case .greaterEqual:
            return ":gte"
        }
    }
}

extension ConditionUnaryOperation {
    var swiftRepresentation: String {
        switch self {
        case .none:
            return ""
        case .negation:
            return "!"
        }
    }

    var xmlRepresentation: String {
        return swiftRepresentation
    }
}
