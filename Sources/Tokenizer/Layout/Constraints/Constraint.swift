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

/**
 * Representative of a `SnapKit.Constraint` along with an optional condition which must be true
 * in order to apply the constraint.
 */
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

    /**
     * Deserializes a single XML attribute (i.e. a field inside an XML element) into an array of constraints.
     * - parameter name: name of the constraint (e.g. top, bottom, leading)
     * - parameter attribute: XML attribute to be parsed
     * - returns: array of deserialized constraints (there can be multiple constraints in one attribute separated by a special symbol)
     */
    public static func constraints(name: String, attribute: XMLAttribute) throws -> [Constraint] {
        let layoutAttributes = try LayoutAttribute.deserialize(name)
        let tokens = Lexer.tokenize(input: attribute.text)
        let constraints = try layoutAttributes.flatMap { try ConstraintParser(tokens: tokens, layoutAttribute: $0).parse() }

        guard
            constraints.count > 1,
            let field = constraints.first?.field
        else { return constraints }

        return constraints.map { currentConstraint in
            var constraint = currentConstraint
            constraint.field = field + "\(currentConstraint.attribute)".capitalizingFirstLetter()
            return constraint
        }
    }

    /**
     * Serializes the constraint into an XML attribute.
     * - returns: XML attribute containing the XML representation of the constraint
     */
    func serialize() -> XMLSerializableAttribute {
        var value = [] as [String]
        
        if let field = field {
            value += "\(field) ="
        }

        if let condition = self.condition {
            value += "[\(condition.generateXML())]"
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
            case .identifier(let id):
                targetString = id
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
            case .readableContentGuide:
                targetString = "readableContentGuide"
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
