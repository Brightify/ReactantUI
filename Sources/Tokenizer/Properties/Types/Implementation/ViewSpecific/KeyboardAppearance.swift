//
//  KeyboardAppearance.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 20/06/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum KeyboardAppearance: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIKeyboardAppearance"

    case `default`
    case dark
    case light

    static var allValues: [KeyboardAppearance] = [.`default`, .dark, .light]

    public static var xsdType: XSDType {
        let values = Set(KeyboardAppearance.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: KeyboardAppearance.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
    import UIKit

    extension KeyboardAppearance {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
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
