//
//  Condition.swift
//  Differentiator-iOS
//
//  Created by Robin Krenecky on 27/04/2018.
//

import Foundation
#if ReactantRuntime
import UIKit
#endif

struct ConditionError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}

public struct InterfaceState {
    public let interfaceIdiom: InterfaceIdiom
    public let horizontalSizeClass: InterfaceSizeClass
    public let verticalSizeClass: InterfaceSizeClass
    public let deviceOrientation: DeviceOrientation
    public let rootDimensions: (width: Float, height: Float)

    public init(interfaceIdiom: InterfaceIdiom, horizontalSizeClass: InterfaceSizeClass,
                verticalSizeClass: InterfaceSizeClass, deviceOrientation: DeviceOrientation,
                rootDimensions: (width: Float, height: Float)) {

        self.interfaceIdiom = interfaceIdiom
        self.horizontalSizeClass = horizontalSizeClass
        self.verticalSizeClass = verticalSizeClass
        self.deviceOrientation = deviceOrientation
        self.rootDimensions = rootDimensions
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

    #if ReactantRuntime
    func evaluate(from interfaceState: InterfaceState, in view: UIView) throws -> Bool {
        switch self {
        case .statement(let statement):
            return try statement.evaluate(from: interfaceState)
        case .unary(let operation, let condition):
            return try condition.evaluate(from: interfaceState, in: view) == (operation != .negation)
        case .binary(let operation, let lhsCondition, let rhsCondition):
            switch operation {
            case .and:
                return try lhsCondition.evaluate(from: interfaceState, in: view) && rhsCondition.evaluate(from: interfaceState, in: view)
            case .or:
                return try lhsCondition.evaluate(from: interfaceState, in: view) || rhsCondition.evaluate(from: interfaceState, in: view)
            case .equal:
                return try lhsCondition.evaluate(from: interfaceState, in: view) == rhsCondition.evaluate(from: interfaceState, in: view)
            case .less, .lessEqual, .greater, .greaterEqual:
                return try compare(from: interfaceState, in: view)
            }
        }
    }

    func compare(from interfaceState: InterfaceState, in view: UIView) throws -> Bool {
        guard case .binary(let operation, let lhsCondition, let rhsCondition) = self else {
            fatalError("Comparation evaluation somehow got called with a nonbinary condition.")
        }
        guard case .statement(let lhsStatement) = lhsCondition, case .statement(let rhsStatement) = rhsCondition else {
            throw ConditionError("Cannot evaluate comparison from two conditions, please compare only two factors (don't use parentheses).")
        }
        let lhsValue = lhsStatement.numberValue(in: view)
        let rhsValue = rhsStatement.numberValue(in: view)
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

public enum ConditionStatement {
    case interfaceIdiom(InterfaceIdiom)
    case sizeClass(SizeClassType, InterfaceSizeClass)
    case interfaceSizeClass(InterfaceSizeClass)
    case orientation(DeviceOrientation)
    case trueStatement
    case falseStatement
    case number(Float)
    case dimensionType(DimensionType)

    public var isComparable: Bool {
        switch self {
        case .number, .dimensionType:
            return true
        case .interfaceIdiom, .sizeClass, .interfaceSizeClass, .orientation, .trueStatement, .falseStatement:
            return false
        }
    }

    init?(identifier: String) {
        let lowerIdentifier = identifier.lowercased()
        switch lowerIdentifier {
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
        case "width":
            self = .dimensionType(.width)
        case "height":
            self = .dimensionType(.height)
        default:
            return nil
        }
    }

    func mergeWith(statement: ConditionStatement) -> ConditionStatement? {
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

    #if ReactantRuntime
    func numberValue(in view: UIView) -> Float {
        switch self {
        case .interfaceIdiom, .sizeClass, .orientation, .trueStatement, .falseStatement, .interfaceSizeClass:
            fatalError("Requested `numberValue` from a logical condition statement.")
        case .number(let value):
            return value
        case .dimensionType(let type):
            switch type {
            case .width:
                return view.traits.viewRootSize(.width)
            case .height:
                return view.traits.viewRootSize(.height)
            }
        }
    }

    func evaluate(from interfaceState: InterfaceState) throws -> Bool {
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
        case .number:
            throw ConditionError("Can't evaluate number only.")
        case .interfaceSizeClass:
            throw ConditionError("Can't evaluate interfaceSizeClass only.")
        case .dimensionType:
            throw ConditionError("Can't evaluate dimensionType only.")
        }
    }
    #endif
}

public enum InterfaceIdiom {
    case pad
    case phone
    case tv
    case carPlay
    case unspecified

    var description: String {
        switch self {
        case .pad:
            return "pad"
        case .phone:
            return "phone"
        case .tv:
            return "tv"
        case .carPlay:
            return "carPlay"
        case .unspecified:
            return "unspecified"
        }
    }
}

public enum InterfaceSizeClass {
    case compact
    case regular
    case unspecified

    var description: String {
        switch self {
        case .compact:
            return "compact"
        case .regular:
            return "regular"
        case .unspecified:
            return "unspecified"
        }
    }
}

public enum SizeClassType {
    case horizontal
    case vertical

    var description: String {
        switch self {
        case .horizontal:
            return "horizontal"
        case .vertical:
            return "vertical"
        }
    }
}

public enum DeviceOrientation {
    case landscape
    case portrait
    case faceDown
    case faceUp
    case unknown

    var description: String {
        switch self {
        case .landscape:
            return "landscape"
        case .portrait:
            return "portrait"
        case .faceDown:
            return "faceDown"
        case .faceUp:
            return "faceUp"
        case .unknown:
            return "unknown"
        }
    }
}

public enum DimensionType {
    case width
    case height

    var description: String {
        switch self {
        case .width:
            return "width"
        case .height:
            return "height"
        }
    }
}

// MARK: - Generator Extensions
extension Condition {
    public func generateSwift(viewName: String) -> String {
        switch self {
        case .statement(let statement):
            return statement.generateSwift(viewName: viewName)
        case .unary(let operation, let condition):
            return "\(operation.swiftRepresentation)\(condition.generateSwift(viewName: viewName))"
        case .binary(let operation, let lhsCondition, let rhsCondition):
            return [
                lhsCondition.generateSwift(viewName: viewName),
                operation.swiftRepresentation,
                rhsCondition.generateSwift(viewName: viewName),
                ].joined(separator: " ")
        }
    }

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

extension ConditionStatement {
    public func generateSwift(viewName: String) -> String {
        switch self {
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
            return "\(viewName).traits.viewRootSize(\(dimensionType.traitsParameter))"
        case .interfaceSizeClass:
            fatalError("Swift condition code generation reached an undefined point.")
        }
    }

    public func generateXML() -> String {
        switch self {
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
        case .interfaceSizeClass:
            fatalError("XML condition code generation reached an undefined point.")
        }
    }
}

// MARK: - Helper extensions for generating code
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
