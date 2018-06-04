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

    static var allValues: [ViewVisibility] = [.visible, .hidden, .collapsed]

    public static var xsdType: XSDType {
        let values = Set(ViewVisibility.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: ViewVisibility.enumName, base: .string, values: values))
    }
}

public enum ViewCollapseAxis: String, EnumPropertyType {
    public static let enumName = "CollapseAxis"

    case horizontal
    case vertical
    case both

    static var allValues: [ViewCollapseAxis] = [.horizontal, .vertical, .both]

    public static var xsdType: XSDType {
        let values = Set(ViewCollapseAxis.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: ViewCollapseAxis.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
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

#if ReactantRuntime

    extension ViewCollapseAxis {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .both:
                return CollapseAxis.both.rawValue
            case .horizontal:
                return CollapseAxis.horizontal.rawValue
            case .vertical:
                return CollapseAxis.vertical.rawValue
            }
        }
    }
#endif
