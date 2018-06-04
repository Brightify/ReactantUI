//
//  ControlContentHorizontalAlignment.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 02/03/2018.
//

import Foundation

public enum ControlContentHorizontalAlignment: Int, EnumPropertyType, AttributeSupportedPropertyType {

    public static let enumName = "UIControlContentHorizontalAlignment"
    
    case center
    case left
    case right
    case fill
    case leading
    case trailing
    
    public var generated: String {
        switch self {
        case .center:
            return "UIControlContentHorizontalAlignment.center"
        case .left:
            return "UIControlContentHorizontalAlignment.left"
        case .right:
            return "UIControlContentHorizontalAlignment.right"
        case .fill:
            return "UIControlContentHorizontalAlignment.fill"
        case .leading:
            if #available(iOS 11.0, *) {
                return "UIControlContentHorizontalAlignment.leading"
            } else {
                fatalError("leading can only be used on iOS 11 and higher")
            }
        case .trailing:
            if #available(iOS 11.0, *) {
                return "UIControlContentHorizontalAlignment.trailing"
            } else {
                fatalError("trailing can only be used on iOS 11 and higher")
            }
        }
    }
    
    #if SanAndreas

    public func dematerialize() -> String {
        switch self {
            case .center:
                return "center"
            case .left:
                return "left"
            case .right:
                return "right"
            case .fill:
                return "fill"
            case .leading:
                return "leading"
            case .trailing:
                return "trailing"
        }
    }

    #endif
    
    public static func materialize(from value: String) throws -> ControlContentHorizontalAlignment {
        let materialized: ControlContentHorizontalAlignment
        switch value {
        case "center":
            materialized = .center
        case "left":
            materialized = .left
        case "right":
            materialized = .right
        case "fill":
            materialized = .fill
        case "leading":
            materialized = .leading
        case "trailing":
            materialized = .trailing
        default:
            throw PropertyMaterializationError.unknownValue(value)
        }
        
        return materialized
    }

    public static var xsdType: XSDType {
        let values = Set(arrayLiteral: "center", "left", "right", "fill", "leading", "trailing")
        return .enumeration(EnumerationXSDType(name: ControlContentHorizontalAlignment.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
    import UIKit
    
    extension ControlContentHorizontalAlignment {
        public var runtimeValue: Any? {
            switch self {
            case .center:
                return UIControlContentHorizontalAlignment.center.rawValue
            case .left:
                return UIControlContentHorizontalAlignment.left.rawValue
            case .right:
                return UIControlContentHorizontalAlignment.right.rawValue
            case .fill:
                return UIControlContentHorizontalAlignment.fill.rawValue
            case .leading:
                if #available(iOS 11.0, tvOS 11.0, *) {
                    return UIControlContentHorizontalAlignment.leading.rawValue
                } else {
                    return nil
                }
            case .trailing:
                if #available(iOS 11.0, tvOS 11.0, *) {
                    return UIControlContentHorizontalAlignment.trailing.rawValue
                } else {
                    return nil
                }
            }
        }
    }
#endif
