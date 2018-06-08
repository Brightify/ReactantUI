//
//  ActivityIndicatorStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 26/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ActivityIndicatorStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIActivityIndicatorViewStyle"

    case whiteLarge
    case white
    case gray

    static var allValues: [ActivityIndicatorStyle] = [.whiteLarge, .white, .gray]

    public static var xsdType: XSDType {
        let values = Set(ActivityIndicatorStyle.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: ActivityIndicatorStyle.enumName, base: .string, values: values))
    }
}

#if canImport(UIKit)
    import UIKit

    extension ActivityIndicatorStyle {
        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            #if os(tvOS)
            switch self {
            case .whiteLarge:
                return UIActivityIndicatorViewStyle.whiteLarge.rawValue
            case .white:
                return UIActivityIndicatorViewStyle.white.rawValue
            default:
                return nil
            }
            #else
                switch self {
                case .whiteLarge:
                    return UIActivityIndicatorViewStyle.whiteLarge.rawValue
                case .white:
                    return UIActivityIndicatorViewStyle.white.rawValue
                case .gray:
                    return UIActivityIndicatorViewStyle.gray.rawValue
                }
            #endif
        }
    }
#endif
