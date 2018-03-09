//
//  ScrollViewIndicatorStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 28/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ScrollViewIndicatorStyle: String, EnumPropertyType {
    public static let enumName = "UIScrollViewIndicatorStyle"

    case `default`
    case black
    case white

    static var allValues: [ScrollViewIndicatorStyle] = [.`default`, .black, .white]

    public static var xsdType: XSDType {
        let values = Set(ScrollViewIndicatorStyle.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: ScrollViewIndicatorStyle.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
    import UIKit

    extension ScrollViewIndicatorStyle {

        public var runtimeValue: Any? {
            switch self {
            case .default:
                return UIScrollViewIndicatorStyle.default.rawValue
            case .black:
                return UIScrollViewIndicatorStyle.black.rawValue
            case .white:
                return UIScrollViewIndicatorStyle.white.rawValue
            }
        }
    }
#endif
