//
//  ContentMode.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum ContentMode: String, EnumPropertyType, AttributeSupportedPropertyType, CaseIterable {
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
}

#if canImport(UIKit)
import UIKit

extension ContentMode {

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .scaleToFill:
            return UIView.ContentMode.scaleToFill.rawValue
        case .scaleAspectFill:
            return UIView.ContentMode.scaleAspectFill.rawValue
        case .scaleAspectFit:
            return UIView.ContentMode.scaleAspectFit.rawValue
        case .redraw:
            return UIView.ContentMode.redraw.rawValue
        case .center:
            return UIView.ContentMode.center.rawValue
        case .top:
            return UIView.ContentMode.top.rawValue
        case .bottom:
            return UIView.ContentMode.bottom.rawValue
        case .left:
            return UIView.ContentMode.left.rawValue
        case .right:
            return UIView.ContentMode.right.rawValue
        case .topLeft:
            return UIView.ContentMode.topLeft.rawValue
        case .topRight:
            return UIView.ContentMode.topRight.rawValue
        case .bottomLeft:
            return UIView.ContentMode.bottomLeft.rawValue
        case .bottomRight:
            return UIView.ContentMode.bottomRight.rawValue
        }
    }
}
#endif

