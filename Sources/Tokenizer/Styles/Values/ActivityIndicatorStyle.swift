//
//  ActivityIndicatorStyle.swift
//  Pods
//
//  Created by Matouš Hýbl on 26/04/2017.
//
//

import Foundation

public enum ActivityIndicatorStyle: String {
    case whiteLarge
    case white
    case gray
}

#if ReactantRuntime
    import UIKit

    extension ActivityIndicatorStyle: Applicable {

        public var value: Any? {
            switch self {
            case .whiteLarge:
                return UIActivityIndicatorViewStyle.whiteLarge.rawValue
            case .white:
                return UIActivityIndicatorViewStyle.white.rawValue
            case .gray:
                return UIActivityIndicatorViewStyle.gray.rawValue
            }
        }
    }
#endif
