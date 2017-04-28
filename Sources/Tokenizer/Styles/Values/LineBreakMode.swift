//
//  LineBreakMode.swift
//  Pods
//
//  Created by Matouš Hýbl on 28/04/2017.
//
//

import Foundation

public enum LineBreakMode: String {
    case byWordWrapping
    case byCharWrapping
    case byClipping
    case byTruncatingHead
    case byTruncatingTail
    case byTruncatingMiddle
}

#if ReactantRuntime
import UIKit

extension LineBreakMode: Applicable {

    public var value: Any? {
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
