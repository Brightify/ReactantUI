//
//  LayoutDistribution.swift
//  Reactant
//
//  Created by Matouš Hýbl on 4/9/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum LayoutDistribution: String, EnumPropertyType {
    public static let enumName = "UIStackViewDistribution"

    case fill
    case fillEqually
    case fillProportionaly
    case equalCentering
    case equalSpacing
}

#if ReactantRuntime
    import UIKit

    extension LayoutDistribution {

        public var runtimeValue: Any? {
            switch self {
            case .equalCentering:
                return UIStackViewDistribution.equalCentering.rawValue
            case .equalSpacing:
                return UIStackViewDistribution.equalSpacing.rawValue
            case .fill:
                return UIStackViewDistribution.fill.rawValue
            case .fillEqually:
                return UIStackViewDistribution.fillEqually.rawValue
            case .fillProportionaly:
                return UIStackViewDistribution.fillProportionally.rawValue
            }
        }
    }
#endif
