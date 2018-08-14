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

public enum LayoutAxis: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UILayoutConstraintAxis"

    case vertical
    case horizontal

    public static let allValues: [LayoutAxis] = [.vertical, .horizontal]
}

#if canImport(UIKit)
    import UIKit

    extension LayoutAxis {
        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .vertical:
                return NSLayoutConstraint.Axis.vertical.rawValue
            case .horizontal:
                return NSLayoutConstraint.Axis.horizontal.rawValue
            }
        }
    }
#endif
