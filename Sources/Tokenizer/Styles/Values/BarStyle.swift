//
//  BarStyle.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum BarStyle: String, EnumPropertyType {
    public static let enumName = "UIBarStyle"

    case `default`
    case black
    case blackTranslucent
}

#if ReactantRuntime
import UIKit

extension BarStyle {

        public var runtimeValue: Any? {
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
