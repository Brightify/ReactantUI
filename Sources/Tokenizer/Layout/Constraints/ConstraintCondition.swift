//
//  ConstraintCondition.swift
//  Differentiator-iOS
//
//  Created by Robin Krenecky on 27/04/2018.
//

import Foundation

public struct InterfaceState {
    public let interfaceIdiom: InterfaceIdiom
    public let horizontalSizeClass: InterfaceSizeClass
    public let verticalSizeClass: InterfaceSizeClass
    public let deviceOrientation: DeviceOrientation

    public init(interfaceIdiom: InterfaceIdiom, horizontalSizeClass: InterfaceSizeClass,
                verticalSizeClass: InterfaceSizeClass, deviceOrientation: DeviceOrientation) {

        self.interfaceIdiom = interfaceIdiom
        self.horizontalSizeClass = horizontalSizeClass
        self.verticalSizeClass = verticalSizeClass
        self.deviceOrientation = deviceOrientation
    }
}

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

    func evaluate(from interfaceState: InterfaceState) -> Bool {
        switch self {
        case .statement(let statement):
            return statement.evaluate(from: interfaceState)
        case .conjunction(let firstCondition, let secondCondition):
            return firstCondition.evaluate(from: interfaceState) && secondCondition.evaluate(from: interfaceState)
        case .disjunction(let firstCondition, let secondCondition):
            return firstCondition.evaluate(from: interfaceState) || secondCondition.evaluate(from: interfaceState)
        }
    }
}

public enum ConditionStatement {
    case interfaceIdiom(InterfaceIdiom, conditionValue: Bool)
    case sizeClass(SizeClassType, type: InterfaceSizeClass, conditionValue: Bool)
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
        let sizeClass: InterfaceSizeClass?
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

    func evaluate(from interfaceState: InterfaceState) -> Bool {
        switch self {
        case .interfaceIdiom(let idiom, conditionValue: let value):
            return (idiom == interfaceState.interfaceIdiom) == value
        case .sizeClass(let sizeClass, type: let type, conditionValue: let value):
            if sizeClass == .horizontal {
                return (type == interfaceState.horizontalSizeClass) == value
            } else {
                return (type == interfaceState.verticalSizeClass) == value
            }
        case .orientation(let orientation, conditionValue: let value):
            return (orientation == interfaceState.deviceOrientation) == value
        }
    }
}

public enum InterfaceIdiom {
    case pad
    case phone
    case tv
    case carPlay
}

public enum InterfaceSizeClass {
    case compact
    case regular
}

public enum SizeClassType {
    case horizontal
    case vertical
}

public enum DeviceOrientation {
    case landscape
    case portrait
}
