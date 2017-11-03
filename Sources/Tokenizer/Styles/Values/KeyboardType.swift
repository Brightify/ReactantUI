//
//  KeyboardType.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 20/06/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum KeyboardType: String, EnumPropertyType {
    public static let enumName = "UIKeyboardType"

    case `default`
    case asciiCapable
    case numbersAndPunctuation
    case URL
    case numberPad
    case phonePad
    case namePhonePad
    case emailAddress
    case decimalPad
    case twitter
    case webSearch
    case asciiCapableNumberPad
}

#if ReactantRuntime
    import UIKit

    extension KeyboardType {

        public var runtimeValue: Any? {
            switch self {
            case .`default`:
                return UIKeyboardType.default.rawValue
            case .asciiCapable:
                return UIKeyboardType.asciiCapable.rawValue
            case .numbersAndPunctuation:
                return UIKeyboardType.numbersAndPunctuation.rawValue
            case .URL:
                return UIKeyboardType.URL.rawValue
            case .numberPad:
                return UIKeyboardType.numberPad.rawValue
            case .phonePad:
                return UIKeyboardType.phonePad.rawValue
            case .namePhonePad:
                return UIKeyboardType.namePhonePad.rawValue
            case .emailAddress:
                return UIKeyboardType.emailAddress.rawValue
            case .decimalPad:
                return UIKeyboardType.decimalPad.rawValue
            case .twitter:
                return UIKeyboardType.twitter.rawValue
            case .webSearch:
                return UIKeyboardType.webSearch.rawValue
            case .asciiCapableNumberPad:
                if #available(iOS 10.0, tvOS 10.0, *) {
                    return UIKeyboardType.asciiCapableNumberPad.rawValue
                } else {
                    return UIKeyboardType.numberPad.rawValue
                }
            }
        }
    }
#endif
