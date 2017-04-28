//
//  ScrollViewIndicatorStyle.swift
//  Pods
//
//  Created by Matouš Hýbl on 28/04/2017.
//
//

import Foundation

public enum ScrollViewIndicatorStyle: String {
    case `default`
    case black
    case white
}

#if ReactantRuntime
    import UIKit

    extension ScrollViewIndicatorStyle: Applicable {

        public var value: Any? {
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
