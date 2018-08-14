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

public enum UnderlineStyle: String, EnumPropertyType, AttributeSupportedPropertyType, CaseIterable {
    public static let enumName = "NSUnderlineStyle"

    case none
    case single
    case thick
    case double
    case patternDot
    case patternDash
    case patternDashDot
    case patternDashDotDot
    case byWord
}

#if canImport(UIKit)
import UIKit

extension UnderlineStyle {

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .none:
            return ([] as NSUnderlineStyle).rawValue
        case .single:
            return NSUnderlineStyle.single.rawValue
        case .thick:
            return NSUnderlineStyle.thick.rawValue
        case .double:
            return NSUnderlineStyle.double.rawValue
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
