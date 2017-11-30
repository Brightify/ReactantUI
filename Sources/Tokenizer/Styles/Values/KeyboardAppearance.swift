//
//  KeyboardAppearance.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 20/06/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum KeyboardAppearance: String, EnumPropertyType {
    public static let enumName = "UIKeyboardAppearance"

    case `default`
    case dark
    case light
}

#if ReactantRuntime
    import UIKit

    extension KeyboardAppearance {

        public var runtimeValue: Any? {
            switch self {
            case .`default`:
                return UIKeyboardAppearance.default.rawValue
            case .dark:
                return UIKeyboardAppearance.dark.rawValue
            case .light:
                return UIKeyboardAppearance.light.rawValue
            }
        }
    }
#endif
