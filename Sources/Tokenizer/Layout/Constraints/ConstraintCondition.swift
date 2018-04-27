//
//  ConstraintCondition.swift
//  Differentiator-iOS
//
//  Created by Robin Krenecky on 27/04/2018.
//

import UIKit

public indirect enum ConstraintCondition {
    case statement(ConditionStatement)
    case conjunction(ConstraintCondition, ConstraintCondition)
    case disjunction(ConstraintCondition, ConstraintCondition)

    var negation: ConstraintCondition {
        switch self {
        case .statement(let statement):
            return .statement(statement.opposite)
        case .conjunction(let firstCondition, let secondCondition):
            return .disjunction(firstCondition.negation, secondCondition.negation)
        case .disjunction(let firstCondition, let secondCondition):
            return .conjunction(firstCondition.negation, secondCondition.negation)
        }
    }
}

extension ConstraintCondition: Equatable {
    public static func == (lhs: ConstraintCondition, rhs: ConstraintCondition) -> Bool {
        switch (lhs, rhs) {
        case (.statement(let lhsStatement), .statement(let rhsStatement)):
            return lhsStatement == rhsStatement
        case (.conjunction(let lhsCondition), .conjunction(let rhsCondition)):
            return lhsCondition == rhsCondition
        case (.disjunction(let lhsCondidtion), .disjunction(let rhsCondition)):
            return lhsCondidtion == rhsCondition
        case (.conjunction(let lhsCondition), .disjunction(let rhsCondition)):
            return lhsCondition.0 == rhsCondition.0.negation && lhsCondition.1 == rhsCondition.1.negation
        case (.disjunction(let lhsCondition), .conjunction(let rhsCondition)):
            return lhsCondition.0.negation == rhsCondition.0 && lhsCondition.1.negation == rhsCondition.1
        case (.disjunction, .statement), (.conjunction, .statement):
            return false
        }
    }
}

public enum ConditionStatement: Equatable {
    case interfaceIdiom(UIUserInterfaceIdiom, conditionValue: Bool)
    case sizeClass(SizeClassType, type: UIUserInterfaceSizeClass, conditionValue: Bool)
    case orientation(DeviceOrientation, conditionValue: Bool)

    var opposite: ConditionStatement {
        switch self {
        case .interfaceIdiom(let idiom, conditionValue: let value):
            return .interfaceIdiom(idiom, conditionValue: !value)
        case .sizeClass(let sizeClass, type: let type, conditionValue: let value):
            return .sizeClass(sizeClass, type: type, conditionValue: !value)
        case .orientation(let orientation, conditionValue: let value):
            return .orientation(orientation, conditionValue: !value)
        }
    }

    init?(identifier: String, type: String? = nil, conditionValue: Bool = true) {
        let sizeClass: UIUserInterfaceSizeClass?
        switch type?.lowercased() {
        case "compact"?:
            sizeClass = .compact
        case "regular"?:
            sizeClass = .regular
        default:
            sizeClass = nil
        }

        switch identifier.lowercased() {
        case "phone", "iphone":
            self = ConditionStatement.interfaceIdiom(.phone, conditionValue: conditionValue)
        case "pad", "ipad":
            self = ConditionStatement.interfaceIdiom(.pad, conditionValue: conditionValue)
        case "tv", "appletv":
            self = ConditionStatement.interfaceIdiom(.tv, conditionValue: conditionValue)
        case "carplay":
            self = ConditionStatement.interfaceIdiom(.carPlay, conditionValue: conditionValue)
        case "horizontal":
            guard let sizeClass = sizeClass else { return nil }
            self = ConditionStatement.sizeClass(.horizontal, type: sizeClass, conditionValue: conditionValue)
        case "vertical":
            guard let sizeClass = sizeClass else { return nil }
            self = ConditionStatement.sizeClass(.vertical, type: sizeClass, conditionValue: conditionValue)
        case "landscape":
            self = ConditionStatement.orientation(.landscape, conditionValue: conditionValue)
        case "portrait":
            self = ConditionStatement.orientation(.portrait, conditionValue: conditionValue)
        default:
            return nil
        }
    }

    private func sizeClassType(type: String?) -> SizeClassType? {
        return .horizontal
    }
}

public enum SizeClassType {
    case horizontal
    case vertical
}

public enum DeviceOrientation {
    case landscape
    case portrait
}
