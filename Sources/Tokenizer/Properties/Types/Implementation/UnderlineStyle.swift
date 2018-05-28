//
//  UnderlineStyle.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 28/05/2018.
//

import Foundation
#if ReactantRuntime
import UIKit
#endif

public enum UnderlineStyle: String, EnumPropertyType {
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

    static var allValues: [UnderlineStyle] = [.styleNone, .styleSingle, .styleThick, .styleDouble,
                                           .patternDot, .patternDash, .patternDashDot, .patternDashDotDot,
                                           .byWord]

    public static var xsdType: XSDType {
        let values = Set(UnderlineStyle.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: UnderlineStyle.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
import UIKit

extension UnderlineStyle {

    public var runtimeValue: Any? {
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
