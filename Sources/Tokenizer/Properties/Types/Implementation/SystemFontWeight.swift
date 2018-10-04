//
//  SystemFontWeight.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif

public enum SystemFontWeight: String, CaseIterable {
    case ultralight
    case thin
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black

    public var name: String {
        switch self {
        case .thin:
            return "UIFont.Weight.thin"
        case .ultralight:
            return "UIFont.Weight.ultraLight"
        case .light:
            return "UIFont.Weight.light"
        case .regular:
            return "UIFont.Weight.regular"
        case .medium:
            return "UIFont.Weight.medium"
        case .semibold:
            return "UIFont.Weight.semibold"
        case .bold:
            return "UIFont.Weight.bold"
        case .heavy:
            return "UIFont.Weight.heavy"
        case .black:
            return "UIFont.Weight.black"
        }
    }

    #if canImport(UIKit)
    public var value: CGFloat {
        switch self {
        case .thin:
            return UIFont.Weight.thin.rawValue
        case .ultralight:
            return UIFont.Weight.ultraLight.rawValue
        case .light:
            return UIFont.Weight.light.rawValue
        case .regular:
            return UIFont.Weight.regular.rawValue
        case .medium:
            return UIFont.Weight.medium.rawValue
        case .semibold:
            return UIFont.Weight.semibold.rawValue
        case .bold:
            return UIFont.Weight.bold.rawValue
        case .heavy:
            return UIFont.Weight.heavy.rawValue
        case .black:
            return UIFont.Weight.black.rawValue
        }
    }
    #endif
}
