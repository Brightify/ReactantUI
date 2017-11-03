//
//  ActivityIndicatorStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 26/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ActivityIndicatorStyle: String, EnumPropertyType {
    public static let enumName = "UIActivityIndicatorViewStyle"

    case whiteLarge
    case white
    case gray
}

#if ReactantRuntime
    import UIKit

    extension ActivityIndicatorStyle {
        public var runtimeValue: Any? {
            #if os(tvOS)
            switch self {
            case .whiteLarge:
                return UIActivityIndicatorViewStyle.whiteLarge.rawValue
            case .white:
                return UIActivityIndicatorViewStyle.white.rawValue
            default:
                return nil
            }
            #else
                switch self {
                case .whiteLarge:
                    return UIActivityIndicatorViewStyle.whiteLarge.rawValue
                case .white:
                    return UIActivityIndicatorViewStyle.white.rawValue
                case .gray:
                    return UIActivityIndicatorViewStyle.gray.rawValue
                }
            #endif
        }
    }
#endif
