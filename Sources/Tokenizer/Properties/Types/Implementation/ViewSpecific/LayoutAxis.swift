//
//  LayoutAxis.swift
//  Hyperdrive-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

#if canImport(UIKit)
    import UIKit
#endif

public enum LayoutAxis: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "NSLayoutConstraint.Axis"

    case vertical
    case horizontal
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
