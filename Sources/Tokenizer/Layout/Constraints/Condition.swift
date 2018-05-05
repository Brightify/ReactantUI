//
//  Condition.swift
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

public indirect enum Condition {
    case statement(ConditionStatement)
    case conjunction(Condition, Condition)
    case disjunction(Condition, Condition)

    var negation: Condition {
        switch self {
        case .statement(let statement):
            return .statement(statement.negation)
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

    static var alwaysTrue: Condition {
        return .statement(.trueStatement)
    }

    static var alwaysFalse: Condition {
        return alwaysTrue.negation
    }
}

public enum ConditionStatement {
    indirect case negated(ConditionStatement)
    case interfaceIdiom(InterfaceIdiom)
    case sizeClass(SizeClassType, type: InterfaceSizeClass)
    case orientation(DeviceOrientation)
    case trueStatement
    case falseStatement

    var negation: ConditionStatement {
        switch self {
        case .interfaceIdiom(let idiom):
            return .negated(.interfaceIdiom(idiom))
        case .sizeClass(let sizeClass, let type):
            return .negated(.sizeClass(sizeClass, type: type))
        case .orientation(let orientation):
            return .negated(.orientation(orientation))
        case .trueStatement:
            return .negated(.falseStatement)
        case .falseStatement:
            return .negated(.trueStatement)
        case .negated(let statement):
            return statement
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
            self = ConditionStatement.interfaceIdiom(.phone)
        case "pad", "ipad":
            self = ConditionStatement.interfaceIdiom(.pad)
        case "tv", "appletv":
            self = ConditionStatement.interfaceIdiom(.tv)
        case "carplay":
            self = ConditionStatement.interfaceIdiom(.carPlay)
        case "horizontal":
            guard let sizeClass = sizeClass else { return nil }
            self = ConditionStatement.sizeClass(.horizontal, type: sizeClass)
        case "vertical":
            guard let sizeClass = sizeClass else { return nil }
            self = ConditionStatement.sizeClass(.vertical, type: sizeClass)
        case "landscape":
            self = ConditionStatement.orientation(.landscape)
        case "portrait":
            self = ConditionStatement.orientation(.portrait)
        default:
            return nil
        }

        if(!conditionValue) {
            self = .negated(self)
        }
    }

    func evaluate(from interfaceState: InterfaceState) -> Bool {
        switch self {
        case .interfaceIdiom(let idiom):
            return idiom == interfaceState.interfaceIdiom
        case .sizeClass(let sizeClass, type: let type):
            if sizeClass == .horizontal {
                return type == interfaceState.horizontalSizeClass
            } else {
                return type == interfaceState.verticalSizeClass
            }
        case .orientation(let orientation):
            return orientation == interfaceState.deviceOrientation
        case .trueStatement:
            return true
        case .falseStatement:
            return false
        case .negated(let statement):
            return !statement.evaluate(from: interfaceState)
        }
    }
}

public enum InterfaceIdiom {
    case pad
    case phone
    case tv
    case carPlay
    case unspecified
}

public enum InterfaceSizeClass {
    case compact
    case regular
    case unspecified
}

public enum SizeClassType {
    case horizontal
    case vertical
}

public enum DeviceOrientation {
    case landscape
    case portrait
    case faceDown
    case faceUp
    case unknown
}
