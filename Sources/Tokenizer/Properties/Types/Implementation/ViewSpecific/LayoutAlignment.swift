//
//  LayoutAlignment.swift
//  Reactant
//
//  Created by Matouš Hýbl on 4/9/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum LayoutAlignment: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIStackViewAlignment"

    case fill
    case firstBaseline
    case lastBaseline
    case leading
    case trailing
    case center

    public static let allValues: [LayoutAlignment] = [.fill, .firstBaseline, .lastBaseline, .leading, .trailing, .center]
}

#if canImport(UIKit)
    import UIKit

    extension LayoutAlignment {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .center:
                return UIStackViewAlignment.center.rawValue
            case .fill:
                return UIStackViewAlignment.fill.rawValue
            case .firstBaseline:
                return UIStackViewAlignment.firstBaseline.rawValue
            case .lastBaseline:
                return UIStackViewAlignment.lastBaseline.rawValue
            case .leading:
                return UIStackViewAlignment.leading.rawValue
            case .trailing:
                return UIStackViewAlignment.trailing.rawValue
            }
        }
    }
#endif
