//
//  ControlContentHorizontalAlignment.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 02/03/2018.
//

import Foundation

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public enum ControlContentHorizontalAlignment: Int, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIControl.ContentHorizontalAlignment"
    
    case center
    case left
    case right
    case fill
    case leading
    case trailing
    
    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        switch self {
        case .center:
            return .constant("UIControl.ContentHorizontalAlignment.center")
        case .left:
            return .constant("UIControl.ContentHorizontalAlignment.left")
        case .right:
            return .constant("UIControl.ContentHorizontalAlignment.right")
        case .fill:
            return .constant("UIControl.ContentHorizontalAlignment.fill")
        case .leading:
            return .constant("UIControl.ContentHorizontalAlignment.leading")
        case .trailing:
            return .constant("UIControl.ContentHorizontalAlignment.trailing")
        }
    }
    #endif
    
    #if SanAndreas

    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
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

#if canImport(UIKit)
    import UIKit
    
    extension ControlContentHorizontalAlignment {
        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .center:
                return UIControl.ContentHorizontalAlignment.center.rawValue
            case .left:
                return UIControl.ContentHorizontalAlignment.left.rawValue
            case .right:
                return UIControl.ContentHorizontalAlignment.right.rawValue
            case .fill:
                return UIControl.ContentHorizontalAlignment.fill.rawValue
            case .leading:
                if #available(iOS 11.0, tvOS 11.0, *) {
                    return UIControl.ContentHorizontalAlignment.leading.rawValue
                } else {
                    return nil
                }
            case .trailing:
                if #available(iOS 11.0, tvOS 11.0, *) {
                    return UIControl.ContentHorizontalAlignment.trailing.rawValue
                } else {
                    return nil
                }
            }
        }
    }
#endif
