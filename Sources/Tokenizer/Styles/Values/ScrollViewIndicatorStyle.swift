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
