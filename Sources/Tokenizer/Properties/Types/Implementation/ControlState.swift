//
//  ControlState.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum ControlState: String, EnumPropertyType {
    public static let enumName = "UIControl.State"

    case normal
    case highlighted
    case disabled
    case selected
    case focused

    public init?(rawValue: String) {
        switch rawValue {
        case "normal":
            self = .normal
        case "highlighted":
            self = .highlighted
        case "disabled":
            self = .disabled
        case "selected":
            self = .selected
        case "focused":
            self = .focused
        default:
            return nil
        }
    }

    public static let allValues: [ControlState] = [.normal, .highlighted, .disabled, .selected, .focused]

    fileprivate static let allValuesDictionary: [ControlState: Int] =
        Dictionary(uniqueKeysWithValues: ControlState.allValues.enumerated().map { ($1, $0) })

    public static var xsdType: XSDType {
        let values = Set(ControlState.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: ControlState.enumName, base: .string, values: values))
    }
}

#if canImport(UIKit)
import UIKit

extension ControlState {

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .normal:
            return UIControl.State.normal.rawValue
        case .highlighted:
            return UIControl.State.highlighted.rawValue
        case .disabled:
            return UIControl.State.disabled.rawValue
        case .selected:
            return UIControl.State.selected.rawValue
        case .focused:
            return UIControl.State.focused.rawValue
        }
    }
}
#endif

public extension Sequence where Element == ControlState {
    public var name: String {

        return sorted(by: { lhs, rhs in
            ControlState.allValuesDictionary[lhs, default: 0] < ControlState.allValuesDictionary[rhs, default: 0]
        }).map { $0.rawValue }.joined(separator: ".")
    }
}

#if canImport(UIKit)
import UIKit

extension ControlState: OptionSetValue {
    var value: UIControl.State {
        switch self {
        case .normal:
            return .normal
        case .highlighted:
            return .highlighted
        case .disabled:
            return .disabled
        case .selected:
            return .selected
        case .focused:
            return .focused
        }
    }
}
#endif
