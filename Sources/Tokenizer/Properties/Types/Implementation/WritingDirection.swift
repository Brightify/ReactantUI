//
//  WritingDirection.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 28/05/2018.
//

import Foundation

public enum WritingDirection: String, EnumPropertyType, AttributeSupportedPropertyType, CaseIterable {
    public static let enumName = "NSWritingDirection"

    case natural
    case leftToRight
    case rightToLeft
}

#if canImport(UIKit)
import UIKit

extension WritingDirection {

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .natural:
            return NSWritingDirection.natural.rawValue
        case .leftToRight:
            return NSWritingDirection.leftToRight.rawValue
        case .rightToLeft:
            return NSWritingDirection.rightToLeft.rawValue
        }
    }
}
#endif
