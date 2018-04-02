//
//  Layout+Serialization.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

extension Layout {
    public func serialize() -> [XMLSerializableAttribute] {
        var builder = XMLAttributeBuilder(namespace: "layout")

        if let id = id {
            builder.attribute(name: "id", value: id)
        }

        if let horizontalCompressionPriority = contentCompressionPriorityHorizontal,
            let verticalCompressionPriority = contentCompressionPriorityVertical,
            horizontalCompressionPriority == verticalCompressionPriority {

            builder.attribute(name: "compressionPriority", value: horizontalCompressionPriority.serialized)
        } else {
            if let horizontalCompressionPriority = contentCompressionPriorityHorizontal {
                builder.attribute(name: "compressionPriority.horizontal", value: horizontalCompressionPriority.serialized)
            }
            if let verticalCompressionPriority = contentCompressionPriorityVertical {
                builder.attribute(name: "compressionPriority.vertical", value: verticalCompressionPriority.serialized)
            }
        }

        if let horizontalHuggingPriority = contentHuggingPriorityHorizontal,
            let verticalHuggingPriority = contentHuggingPriorityVertical,
            horizontalHuggingPriority == verticalHuggingPriority {

            builder.attribute(name: "huggingPriority", value: horizontalHuggingPriority.serialized)
        } else {
            if let horizontalHuggingPriority = contentHuggingPriorityHorizontal {
                builder.attribute(name: "huggingPriority.horizontal", value: horizontalHuggingPriority.serialized)
            }
            if let verticalHuggingPriority = contentHuggingPriorityVertical {
                builder.attribute(name: "huggingPriority.vertical", value: verticalHuggingPriority.serialized)
            }
        }

        ConstraintShortcutOrConstraint.detect(in: constraints)
            .map { $0.serialize() }
            .forEach { builder.add(attribute: $0) }

        return builder.attributes
    }
}

extension ConstraintPriority: Equatable {
    public static func ==(lhs: ConstraintPriority, rhs: ConstraintPriority) -> Bool {
        switch (lhs, rhs) {
        case (.required, .required), (.high, .high), (.medium, .medium), (.low, .low):
            return true
        case (.custom(let lhsValue), .custom(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

extension ConstraintPriority {

    public var serialized: String {
        switch self {
        case .required:
            return "required"
        case .high:
            return "high"
        case .medium:
            return "medium"
        case .low:
            return "low"
        case .custom(let value):
            return "\(value)"
        }
    }
}

extension ConstraintRelation {

    public var serialized: String {
        switch self {
        case .equal:
            return "eq"
        case .lessThanOrEqual:
            return "lt"
        case .greaterThanOrEqual:
            return "gt"
        }
    }

}

private enum ConstraintShortcutOrConstraint {
    case shortcut(shortcut: ConstraintShortcut, Constraint)
    case constraint(Constraint)

    func serialize() -> XMLSerializableAttribute {
        switch self {
        case .shortcut(let shortcut, let constraint):
            var attribute = constraint.serialize()
            attribute.name = shortcut.rawValue
            return attribute

        case .constraint(let constraint):
            return constraint.serialize()
        }
    }

    static func detect(in constraints: [Constraint]) -> [ConstraintShortcutOrConstraint] {
        var mutableConstraints = constraints

        var result = [] as [ConstraintShortcutOrConstraint]
        for shortcut in ConstraintShortcut.allValues {
            let constraintsForShortcut = mutableConstraints.filter { shortcut.attributes.contains($0.attribute) }
            guard constraintsForShortcut.count == shortcut.attributes.count else { continue }
            let grouped = constraintsForShortcut.groupBy { $0.serialize().value }
            for (_, group) in grouped {
                let groupAttributes = Set(group.map { $0.attribute })
                guard groupAttributes == shortcut.attributes else { continue }
                guard let firstConstraint = group.first else { continue }

                result.append(.shortcut(shortcut: shortcut, firstConstraint))
                constraintsForShortcut.forEach { constraint in
                    guard let index = mutableConstraints.index(of: constraint) else { return }
                    mutableConstraints.remove(at: index)
                }
            }

            //            let allConstraintsEqual = equal(constraintsForShortcut) { lhs, rhs in
            //                guard lhs.field == rhs.field else { return false }
            //                guard lhs.relation == rhs.relation else { return false }
            //                guard lhs.priority == rhs.priority else { return false }
            //
            //                switch (lhs.type, rhs.type) {
            //                case (.targeted(let lhsTargeted), .targeted(let rhsTargeted)):
            //                    let conditions: [Bool] = [
            //                        lhsTargeted.targetAnchor == lhs.anchor,
            //                        rhsTargeted.targetAnchor == rhs.anchor,
            //                        lhsTargeted.target == rhsTargeted.target,
            //                        lhsTargeted.constant == rhsTargeted.constant
            //                    ]
            //
            //                    // Check if all conditions are true
            //                    guard conditions.first(where: { $0 == false }) == nil else { return false }
            //                case (.constant(let lhsConstant), .constant(let rhsConstant)):
            //                    guard lhsConstant == rhsConstant else { return false }
            //                default:
            //                    return false
            //                }
            //
            //                // If we get all the way here they are equal
            //                return true
            //            }
            //
            //            guard allConstraintsEqual else { continue }
            //
            //            removedAttributes.append(contentsOf: shortcut.attributes)
            //            shortcut.attributes.forEach { constraintDictionary.removeValue(forKey: $0) }


        }

        result.append(contentsOf: mutableConstraints.map(ConstraintShortcutOrConstraint.constraint))

        return result
    }
}

private enum ConstraintShortcut: String {
    case edges
    case fillHorizontally
    case fillVertically
    case center
    case before
    case after

    var attributes: Set<LayoutAttribute> {
        switch self {
        case .edges:
            return [.left, .right, .top, .bottom]
        case .fillHorizontally:
            return [.left, .right]
        case .fillVertically:
            return [.top, .bottom]
        case .center:
            return [.centerX, .centerY]
        case .before:
            return [.before]
        case .after:
            return [.after]
        }
    }

    static let allValues: [ConstraintShortcut] = [.edges, .fillHorizontally, .fillVertically, .center, .before, .after]
}
