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

    static var allValues: [LayoutAlignment] = [.fill, .firstBaseline, .lastBaseline, .leading, .trailing, .center]

    public static var xsdType: XSDType {
        let values = Set(LayoutAlignment.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: LayoutAlignment.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
    import UIKit

    extension LayoutAlignment {

        public var runtimeValue: Any? {
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
