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

public enum ConditionBinaryOperation {
    case and
    case or
    case equal
}

public enum ConditionUnaryOperation {
    case none
    case negation
}

public indirect enum Condition {
    case statement(ConditionStatement)
    case unary(ConditionUnaryOperation, Condition)
    case binary(ConditionBinaryOperation, Condition, Condition)

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

    func evaluate(from interfaceState: InterfaceState) -> Bool {
        switch self {
        case .statement(let statement):
            return statement.evaluate(from: interfaceState)
        case .unary(let operation, let condition):
            return condition.evaluate(from: interfaceState) == (operation != .negation)
        case .binary(let operation, let firstCondition, let secondCondition):
            switch operation {
            case .and:
                return firstCondition.evaluate(from: interfaceState) && secondCondition.evaluate(from: interfaceState)
            case .or:
                return firstCondition.evaluate(from: interfaceState) || secondCondition.evaluate(from: interfaceState)
            case .equal:
                return firstCondition.evaluate(from: interfaceState) == secondCondition.evaluate(from: interfaceState)
            }
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
    case interfaceIdiom(InterfaceIdiom)
    case sizeClass(SizeClassType, InterfaceSizeClass)
    case interfaceSizeClass(InterfaceSizeClass)
    case orientation(DeviceOrientation)
    case trueStatement
    case falseStatement

    init?(identifier: String) {
        switch identifier.lowercased() {
        case "phone", "iphone":
            self = .interfaceIdiom(.phone)
        case "pad", "ipad":
            self = .interfaceIdiom(.pad)
        case "tv", "appletv":
            self = .interfaceIdiom(.tv)
        case "carplay":
            self = .interfaceIdiom(.carPlay)
        case "horizontal":
            self = .sizeClass(.horizontal, .unspecified)
        case "vertical":
            self = .sizeClass(.vertical, .unspecified)
        case "landscape":
            self = .orientation(.landscape)
        case "portrait":
            self = .orientation(.portrait)
        case "compact":
            self = .interfaceSizeClass(.compact)
        case "regular":
            self = .interfaceSizeClass(.regular)
        case "false":
            self = .falseStatement
        case "true":
            self = .trueStatement
        default:
            return nil
        }
    }

    func mergeWithSizeClass(statement: ConditionStatement) -> ConditionStatement? {
        if case .sizeClass(let sizeClass, _) = self,
            case .interfaceSizeClass(let interfaceSizeClass) = statement {
            return .sizeClass(sizeClass, interfaceSizeClass)
        } else if case .interfaceSizeClass(let interfaceSizeClass) = self,
            case .sizeClass(let sizeClass, _) = statement {
            return .sizeClass(sizeClass, interfaceSizeClass)
        } else {
            return nil
        }
    }

    func evaluate(from interfaceState: InterfaceState) -> Bool {
        switch self {
        case .interfaceIdiom(let idiom):
            return idiom == interfaceState.interfaceIdiom
        case .sizeClass(let sizeClass, let type):
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
        case .interfaceSizeClass:
            fatalError("Can't evaluate interfaceSizeClass only.")
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
