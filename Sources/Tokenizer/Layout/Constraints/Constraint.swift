//
//  Constraint.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

private func +=(lhs: inout [String], rhs: String) {
    lhs.append(rhs)
}

public struct Constraint {
    public var field: String?
    public var condition: Condition?
    public var attribute: LayoutAttribute
    public var type: ConstraintType
    public var relation: ConstraintRelation
    public var priority: ConstraintPriority
    
    public var anchor: LayoutAnchor {
        return attribute.anchor
    }
    
    public init(field: String?,
                condition: Condition?,
                attribute: LayoutAttribute,
                type: ConstraintType,
                relation: ConstraintRelation,
                priority: ConstraintPriority) {
        self.field = field
        self.condition = condition
        self.attribute = attribute
        self.type = type
        self.relation = relation
        self.priority = priority
    }
    
    public static func constraints(name: String, attribute: XMLAttribute) throws -> [Constraint] {
        let layoutAttributes = try LayoutAttribute.deserialize(name)
        let tokens = Lexer.tokenize(input: attribute.text)
        return try layoutAttributes.flatMap { try ConstraintParser(tokens: tokens, layoutAttribute: $0).parse() }
    }
    
    func serialize() -> XMLSerializableAttribute {
        var value = [] as [String]
        
        if let field = field {
            value += "\(field) ="
        }

        if let condition = self.condition {
            value += "[\(generateXMLCondition(condition: condition))]"
        }
        
        if relation != .equal {
            value += ":\(relation.serialized)"
        }

        switch type {
        case .constant(let constant):
            value += "\(constant)"
        case .targeted(let target, let targetAnchor, let multiplier, let constant):
            var targetString: String
            switch target {
            case .field(let field):
                targetString = "\(field)"
            case .layoutId(let layoutId):
                targetString = "id:\(layoutId)"
            case .parent:
                targetString = "super"
            case .this:
                targetString = "self"
            case .safeAreaLayoutGuide:
                if #available(iOS 11.0, tvOS 11.0, *) {
                    targetString = "safeAreaLayoutGuide"
                } else {
                    targetString = "fallback_safeAreaLayoutGuide"
                }
            }
            if targetAnchor != anchor && attribute != .before && attribute != .after {
                targetString += ".\(targetAnchor.description)"
            }
            value += targetString
            
            if multiplier != 1 {
                if multiplier > 1 {
                    value += "multiplied(by: \(multiplier))"
                } else {
                    value += "divided(by: \(1 / multiplier))"
                }
            }
            
            if constant != 0 {
                if case .parent = target, constant > 0 || attribute.insetDirection < 0 {
                    value += "inset(by: \(constant * attribute.insetDirection))"
                } else {
                    value += "offset(by: \(constant))"
                }
            }
        }
        
        if priority != ConstraintPriority.required {
            value += "@\(priority.serialized)"
        }
        
        return XMLSerializableAttribute(name: anchor.description, value: value.joined(separator: " "))
    }

    // MARK: Swift condition generators
    public func generateSwiftCondition(condition: Condition, viewName: String) -> String {
        switch condition {
        case .statement(let statement):
            return generateSwiftCondition(statement: statement, viewName: viewName)
        case .unary(let operation, let condition):
            return "\(operation.swiftRepresentation)\(generateSwiftCondition(condition: condition, viewName: viewName))"
        case .binary(let operation, let lhsCondition, let rhsCondition):
            return [
                generateSwiftCondition(condition: lhsCondition, viewName: viewName),
                operation.swiftRepresentation,
                generateSwiftCondition(condition: rhsCondition, viewName: viewName),
            ].joined(separator: " ")
        }
    }

    public func generateSwiftCondition(statement: ConditionStatement, viewName: String) -> String {
        switch statement {
        case .trueStatement:
            return "true"
        case .falseStatement:
            return "false"
        case .sizeClass(let sizeClassType, let viewInterfaceSize):
            return "\(viewName).traits.size(\(sizeClassType.traitsParameter): \(viewInterfaceSize.traitsParameter))"
        case .interfaceIdiom(let interfaceIdiom):
            return "\(viewName).traits.device(\(interfaceIdiom.traitsParameter))"
        case .orientation(let orientation):
            return "\(viewName).traits.orientation(\(orientation.traitsParameter))"
        case .number(let number):
            return String(number)
        case .dimensionType(let dimensionType):
            return "\(viewName).traits.topViewSize(\(dimensionType.traitsParameter))"
        default:
            return ""
        }
    }

    // MARK: - XML condition generators
    public func generateXMLCondition(condition: Condition) -> String {
        switch condition {
        case .statement(let statement):
            return generateXMLCondition(statement: statement)
        case .unary(let operation, let condition):
            return "\(operation.xmlRepresentation)\(generateXMLCondition(condition: condition))"
        case .binary(let operation, let lhsCondition, let rhsCondition):
            return [
                generateXMLCondition(condition: lhsCondition),
                operation.xmlRepresentation,
                generateXMLCondition(condition: rhsCondition),
            ].joined(separator: " ")
        }
    }

    public func generateXMLCondition(statement: ConditionStatement) -> String {
        switch statement {
        case .trueStatement:
            return "true"
        case .falseStatement:
            return "false"
        case .sizeClass(let sizeClassType, let viewInterfaceSize):
            return "\(sizeClassType.description) == \(viewInterfaceSize.description)"
        case .interfaceIdiom(let interfaceIdiom):
            return interfaceIdiom.description
        case .orientation(let orientation):
            return orientation.description
        case .number(let number):
            return String(number)
        case .dimensionType(let dimensionType):
            return dimensionType.description
        default:
            return ""
        }
    }
}

struct ConditionError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
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
        case .greater:
            return ">"
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
        case .greater:
            return ":gt"
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
        switch self {
        case .none:
            return swiftRepresentation
        case .negation:
            return swiftRepresentation
        }
    }
}

extension SizeClassType {
    fileprivate var traitsParameter: String {
        switch self {
        case .horizontal:
            return "horizontal"
        case .vertical:
            return "vertical"
        }
    }
}

extension InterfaceSizeClass {
    fileprivate var traitsParameter: String {
        switch self {
        case .regular:
            return "UIUserInterfaceSizeClass.regular"
        case .compact:
            return "UIUserInterfaceSizeClass.compact"
        case .unspecified:
            return "UIUserInterfaceSizeClass.unspecified"
        }
    }
}

extension InterfaceIdiom {
    fileprivate var traitsParameter: String {
        switch self {
        case .phone:
            return ".phone"
        case .pad:
            return ".pad"
        case .tv:
            return ".tv"
        case .carPlay:
            return ".carPlay"
        case .unspecified:
            return ".unspecified"
        }
    }
}

extension DeviceOrientation {
    fileprivate var traitsParameter: String {
        switch self {
        case .faceDown:
            return ".faceDown"
        case .faceUp:
            return ".faceUp"
        case .portrait:
            return ".portrait"
        case .landscape:
            return ".landscape"
        case .unknown:
            return ".unknown"
        }
    }
}

extension DimensionType {
    fileprivate var traitsParameter: String {
        switch self {
        case .width:
            return ".width"
        case .height:
            return ".height"
        }
    }
}

extension Constraint: Equatable {
    public static func ==(lhs: Constraint, rhs: Constraint) -> Bool {
        return lhs.field == rhs.field
            && lhs.attribute == rhs.attribute
            && lhs.priority == rhs.priority
            && lhs.relation == rhs.relation
            && lhs.type == rhs.type
    }
}
