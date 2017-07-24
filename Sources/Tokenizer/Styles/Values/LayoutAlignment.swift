//
//  LayoutAlignment.swift
//  Reactant
//
//  Created by Matouš Hýbl on 4/9/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum LayoutAlignment: String, EnumPropertyType {
    public static let enumName = "UIStackViewAlignment"

    case fill
    case firstBaseline
    case lastBaseline
    case leading
    case trailing
    case center
}

#if ReactantRuntime
    import UIKit

    extension LayoutAlignment {

        public var runtimeValue: Any? {
            switch self {
            case .center:
                return UIStackViewAlignment.center.rawValue
            case .fill:
                return UIStackViewAlignment.fill.rawValue
            case .firstBaseline:
                return UIStackViewAlignment.firstBaseline.rawValue
            case .lastBaseline:
                return UIStackViewAlignment.lastBaseline.rawValue
            case .leading:
                return UIStackViewAlignment.leading.rawValue
            case .trailing:
                return UIStackViewAlignment.trailing.rawValue
            }
        }
    }
#endif
