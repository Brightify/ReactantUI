//
//  KeyboardAppearance.swift
//  Pods
//
//  Created by Matyáš Kříž on 20/06/2017.
//
//

import Foundation

public enum KeyboardAppearance: String {
    case `default`
    case dark
    case light
}

#if ReactantRuntime
    import UIKit

    extension KeyboardAppearance: Applicable {

        public var value: Any? {
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
