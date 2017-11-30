//
//  LineBreakMode.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 28/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum LineBreakMode: String, EnumPropertyType {
    public static let enumName = "NSLineBreakMode"

    case byWordWrapping
    case byCharWrapping
    case byClipping
    case byTruncatingHead
    case byTruncatingTail
    case byTruncatingMiddle
}

#if ReactantRuntime
import UIKit

extension LineBreakMode {

    public var runtimeValue: Any? {
        switch self {
        case .byWordWrapping:
            return NSLineBreakMode.byWordWrapping.rawValue
        case .byCharWrapping:
            return NSLineBreakMode.byCharWrapping.rawValue
        case .byClipping:
            return NSLineBreakMode.byClipping.rawValue
        case .byTruncatingHead:
            return NSLineBreakMode.byTruncatingHead.rawValue
        case .byTruncatingTail:
            return NSLineBreakMode.byTruncatingTail.rawValue
        case .byTruncatingMiddle:
            return NSLineBreakMode.byTruncatingMiddle.rawValue
        }
    }
}
#endif
