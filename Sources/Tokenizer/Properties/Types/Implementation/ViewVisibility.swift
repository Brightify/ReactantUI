//
//  ViewVisibility.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 26/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ViewVisibility: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "Visibility"

    case visible
    case hidden
    case collapsed

    public static var allValues: [ViewVisibility] = [.visible, .hidden, .collapsed]

    public static var runtimeType: String = "Reactant.Visibility"

    public static var xsdType: XSDType {
        let values = Set(ViewVisibility.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: ViewVisibility.enumName, base: .string, values: values))
    }
}

#if canImport(UIKit)
import Reactant

extension ViewVisibility {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .visible:
            return Visibility.visible.rawValue
        case .collapsed:
            return Visibility.collapsed.rawValue
        case .hidden:
            return Visibility.hidden.rawValue
        }
    }
}
#endif
