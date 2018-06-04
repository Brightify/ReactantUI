//
//  LineBreakMode.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 28/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum LineBreakMode: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "NSLineBreakMode"

    case byWordWrapping
    case byCharWrapping
    case byClipping
    case byTruncatingHead
    case byTruncatingTail
    case byTruncatingMiddle

    static var allValues: [LineBreakMode] = [.byWordWrapping, .byCharWrapping, .byClipping,
                                             .byTruncatingHead, .byTruncatingTail, .byTruncatingMiddle]

    public static var xsdType: XSDType {
        let values = Set(LineBreakMode.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: LineBreakMode.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
import UIKit

extension LineBreakMode {

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .byWordWrapping:
            return NSLineBreakMode.byWordWrapping.rawValue
        case .byCharWrapping:
            return NSLineBreakMode.byCharWrapping.rawValue
        case .byClipping:
            return NSLineBreakMode.byClipping.rawValue
        case .byTruncatingHead:
            return NSLineBreakMode.byTruncatingHead.rawValue
        case .byTruncatingTail:
            return NSLineBreakMode.byTruncatingTail.rawValue
        case .byTruncatingMiddle:
            return NSLineBreakMode.byTruncatingMiddle.rawValue
        }
    }
}
#endif
