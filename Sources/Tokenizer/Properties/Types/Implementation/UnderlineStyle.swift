//
//  UnderlineStyle.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 28/05/2018.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum UnderlineStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "NSUnderlineStyle"

    case styleNone
    case styleSingle
    case styleThick
    case styleDouble
    case patternDot
    case patternDash
    case patternDashDot
    case patternDashDotDot
    case byWord

    public static let allValues: [UnderlineStyle] = [.styleNone, .styleSingle, .styleThick, .styleDouble,
                                           .patternDot, .patternDash, .patternDashDot, .patternDashDotDot,
                                           .byWord]
}

#if canImport(UIKit)
import UIKit

extension UnderlineStyle {

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .styleNone:
            return NSUnderlineStyle.styleNone.rawValue
        case .styleSingle:
            return NSUnderlineStyle.styleSingle.rawValue
        case .styleThick:
            return NSUnderlineStyle.styleThick.rawValue
        case .styleDouble:
            return NSUnderlineStyle.styleDouble.rawValue
        case .patternDot:
            return NSUnderlineStyle.patternDot.rawValue
        case .patternDash:
            return NSUnderlineStyle.patternDash.rawValue
        case .patternDashDot:
            return NSUnderlineStyle.patternDashDot.rawValue
        case .patternDashDotDot:
            return NSUnderlineStyle.patternDashDotDot.rawValue
        case .byWord:
            return NSUnderlineStyle.byWord.rawValue
        }
    }
}
#endif
