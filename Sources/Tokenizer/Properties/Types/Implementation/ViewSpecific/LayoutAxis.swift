//
//  LayoutAxis.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

#if canImport(UIKit)
    import UIKit
#endif

public enum LayoutAxis: String, AttributeSupportedPropertyType {
    case vertical
    case horizontal

    public func generate(context: SupportedPropertyTypeContext) -> String {
        switch self {
        case .vertical:
            return "UILayoutConstraintAxis.vertical"
        case .horizontal:
            return "UILayoutConstraintAxis.horizontal"
        }
    }

    static var allValues: [LayoutAxis] = [.vertical, .horizontal]

    public static var xsdType: XSDType {
        let values = Set(LayoutAxis.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: "LayoutAxis", base: .string, values: values))
    }
}

#if canImport(UIKit)
    import UIKit

    extension LayoutAxis {
        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .vertical:
                return UILayoutConstraintAxis.vertical.rawValue
            case .horizontal:
                return UILayoutConstraintAxis.horizontal.rawValue
            }
        }
    }
#endif
