//
//  LayoutAxis.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

public enum LayoutAxis: String, SupportedPropertyType {
    case vertical
    case horizontal

    public var generated: String {
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

#if ReactantRuntime
    import UIKit

    extension LayoutAxis {
        public var runtimeValue: Any? {
            switch self {
            case .vertical:
                return UILayoutConstraintAxis.vertical.rawValue
            case .horizontal:
                return UILayoutConstraintAxis.horizontal.rawValue
            }
        }
    }
#endif
