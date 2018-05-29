//
//  ContentMode.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum ContentMode: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIViewContentMode"

    case scaleToFill
    case scaleAspectFit
    case scaleAspectFill
    case redraw
    case center
    case top
    case bottom
    case left
    case right
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    public static let allValues: [ContentMode] = [.scaleToFill, .scaleAspectFit, .scaleAspectFill,
                                                  .redraw, .center, .top, .bottom, .left, .right,
                                                  .topLeft, .topRight, .bottomLeft, .bottomRight]
}

#if canImport(UIKit)
import UIKit

extension ContentMode {

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .scaleToFill:
            return UIViewContentMode.scaleToFill.rawValue
        case .scaleAspectFill:
            return UIViewContentMode.scaleAspectFill.rawValue
        case .scaleAspectFit:
            return UIViewContentMode.scaleAspectFit.rawValue
        case .redraw:
            return UIViewContentMode.redraw.rawValue
        case .center:
            return UIViewContentMode.center.rawValue
        case .top:
            return UIViewContentMode.top.rawValue
        case .bottom:
            return UIViewContentMode.bottom.rawValue
        case .left:
            return UIViewContentMode.left.rawValue
        case .right:
            return UIViewContentMode.right.rawValue
        case .topLeft:
            return UIViewContentMode.topLeft.rawValue
        case .topRight:
            return UIViewContentMode.topRight.rawValue
        case .bottomLeft:
            return UIViewContentMode.bottomLeft.rawValue
        case .bottomRight:
            return UIViewContentMode.bottomRight.rawValue
        }
    }
}
#endif

