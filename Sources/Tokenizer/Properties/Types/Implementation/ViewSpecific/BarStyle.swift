//
//  BarStyle.swift
//  Hyperdrive
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum BarStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIBarStyle"

    case `default`
    case black
    case blackTranslucent
}

#if canImport(UIKit)
import UIKit

extension BarStyle {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        #if os(tvOS)
            return nil
        #else
            switch self {
            case .`default`:
                return UIBarStyle.default.rawValue
            case .black:
                return UIBarStyle.black.rawValue
            case .blackTranslucent:
                return UIBarStyle.blackTranslucent.rawValue
            }
        #endif
    }
}
#endif
