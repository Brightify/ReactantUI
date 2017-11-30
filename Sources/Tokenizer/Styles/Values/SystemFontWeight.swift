//
//  SystemFontWeight.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum SystemFontWeight: String {
    public static let allValues: [SystemFontWeight] = [
        .thin, .ultralight, .light, .regular, .medium, .semibold, .bold, .heavy, .black
    ]

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
            return "UIFontWeightThin"
        case .ultralight:
            return "UIFontWeightUltraLight"
        case .light:
            return "UIFontWeightLight"
        case .regular:
            return "UIFontWeightRegular"
        case .medium:
            return "UIFontWeightMedium"
        case .semibold:
            return "UIFontWeightSemibold"
        case .bold:
            return "UIFontWeightBold"
        case .heavy:
            return "UIFontWeightHeavy"
        case .black:
            return "UIFontWeightBlack"
        }
    }

    #if ReactantRuntime
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
