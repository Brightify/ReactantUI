//
//  ConditionStatement.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 03/08/2018.
//

import Foundation
// canImport(Common) is required because there's no module "Common" in ReactantLiveUI
#if canImport(Common)
import Common
#endif
#if canImport(UIKit)
import UIKit
#endif

/**
 * Constraint-focused condition statement. It's the bearer of the data inside `Condition` nodes.
 */
public enum ConditionStatement {
    case trueStatement
    case falseStatement
    case number(Double)
    case interfaceIdiom(InterfaceIdiom)
    case sizeClass(SizeClassType, InterfaceSizeClass)
    case interfaceSizeClass(InterfaceSizeClass)
    case orientation(ViewOrientation)
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

    #if canImport(UIKit)
    func numberValue(from traits: UITraitHelper) -> Double {
        switch self {
        case .interfaceIdiom, .sizeClass, .orientation, .trueStatement, .falseStatement, .interfaceSizeClass:
            fatalError("Requested `numberValue` from a logical condition statement.")
        case .number(let value):
            return value
        case .dimensionType(let type):
            switch type {
            case .width:
                return traits.viewRootSize(.width)
            case .height:
                return traits.viewRootSize(.height)
            }
        }
    }

    func evaluate(from traits: UITraitHelper) throws -> Bool {
        switch self {
        case .interfaceIdiom(let idiom):
            return traits.device(idiom.runtimeValue)
        case .sizeClass(let type, let sizeClass):
            if type == .horizontal {
                return traits.size(horizontal: sizeClass.runtimeValue)
            } else {
                return traits.size(vertical: sizeClass.runtimeValue)
            }
        case .orientation(let orientation):
            return traits.orientation(orientation)
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

// MARK: - Generator Extension
extension ConditionStatement {
    public func generateSwift(viewName: String) -> String {
        switch self {
        case .trueStatement:
            return "true"
        case .falseStatement:
            return "false"
        case .sizeClass(let sizeClassType, let viewInterfaceSize):
            return "\(viewName).traits.size(\(sizeClassType.description): .\(viewInterfaceSize.description))"
        case .interfaceIdiom(let interfaceIdiom):
            return "\(viewName).traits.device(.\(interfaceIdiom.description))"
        case .orientation(let orientation):
            return "\(viewName).traits.orientation(.\(orientation.description))"
        case .number(let number):
            return String(number)
        case .dimensionType(let dimensionType):
            return "\(viewName).traits.viewRootSize(.\(dimensionType.description))"
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
