//
//  ControlContentVerticalAlignment.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 02/03/2018.
//

import Foundation

public enum ControlContentVerticalAlignment: Int, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIControlContentVerticalAlignment"
    
    case center
    case top
    case bottom
    case fill

    public static let allValues: [ControlContentVerticalAlignment] = [.center, .top, .bottom, .fill]
    
    public func generate(context: SupportedPropertyTypeContext) -> String {
        switch self {
        case .center:
            return "UIControlContentVerticalAlignment.center"
        case .top:
            return "UIControlContentVerticalAlignment.top"
        case .bottom:
            return "UIControlContentVerticalAlignment.bottom"
        case .fill:
            return "UIControlContentVerticalAlignment.fill"
        }
    }
    
    #if SanAndreas

    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        switch self {
            case .center:
                return "center"
            case .top:
                return "top"
            case .bottom:
                return "bottom"
            case .fill:
                return "fill"
        }
    }

    #endif
    
    public static func materialize(from value: String) throws -> ControlContentVerticalAlignment {
        let materialized: ControlContentVerticalAlignment
        switch value {
        case "center":
            materialized = .center
        case "top":
            materialized = .top
        case "bottom":
            materialized = .bottom
        case "fill":
            materialized = .fill
        default:
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }

    public static var xsdType: XSDType {
        let values = Set(arrayLiteral: "center", "top", "bottom", "fill")
        return .enumeration(EnumerationXSDType(name: ControlContentVerticalAlignment.enumName, base: .string, values: values))
    }
}

#if canImport(UIKit)
    import UIKit
    
    extension ControlContentVerticalAlignment {
        
        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .center:
                return UIControlContentVerticalAlignment.center.rawValue
            case .top:
                return UIControlContentVerticalAlignment.top.rawValue
            case .bottom:
                return UIControlContentVerticalAlignment.bottom.rawValue
            case .fill:
                return UIControlContentVerticalAlignment.fill.rawValue
            }
        }
    }
#endif
