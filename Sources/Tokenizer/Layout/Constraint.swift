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
    public var attribute: LayoutAttribute
    public var type: ConstraintType
    public var relation: ConstraintRelation
    public var priority: ConstraintPriority
    
    public var anchor: LayoutAnchor {
        return attribute.anchor
    }
    
    public init(field: String?, attribute: LayoutAttribute, type: ConstraintType, relation: ConstraintRelation, priority: ConstraintPriority) {
        self.field = field
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
    
    func serialize() -> MagicAttribute {
        var value = [] as [String]
        
        if let field = field {
            value += "\(field) ="
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
        
        return MagicAttribute(name: anchor.description, value: value.joined(separator: " "))
    }
}

public enum ConstraintType {
    case constant(Float)
    case targeted(target: ConstraintTarget, targetAnchor: LayoutAnchor, multiplier: Float, constant: Float)
}

extension ConstraintType: Equatable {
    public static func ==(lhs: ConstraintType, rhs: ConstraintType) -> Bool {
        switch(lhs, rhs) {
        case (.constant(let lhsConstant), .constant(let rhsConstant)):
            return lhsConstant == rhsConstant
        case (.targeted(let lhsTarget, let lhsAnchor, let lhsMultiplier, let lhsConstant), .targeted(let rhsTarget, let rhsAnchor, let rhsMultiplier, let rhsConstant)):
            return lhsTarget == rhsTarget && lhsAnchor == rhsAnchor && lhsMultiplier == rhsMultiplier && lhsConstant == rhsConstant
        default:
            return false
        }
    }
}

public enum ConstraintTarget {
    case field(String)
    case layoutId(String)
    case parent
    case this
    case safeAreaLayoutGuide
}

extension ConstraintTarget: Equatable {
    public static func ==(lhs: ConstraintTarget, rhs: ConstraintTarget) -> Bool {
        switch (lhs, rhs) {
        case (.field(let lhsField), .field(let rhsField)):
            return lhsField == rhsField
        case (.layoutId(let lhsId), .layoutId(let rhsId)):
            return lhsId == rhsId
        case (.parent, .parent), (.this, .this), (.safeAreaLayoutGuide, .safeAreaLayoutGuide):
            return true
        default:
            return false
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
