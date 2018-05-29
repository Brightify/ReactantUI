//
//  LayoutDistribution.swift
//  Reactant
//
//  Created by Matouš Hýbl on 4/9/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum LayoutDistribution: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIStackViewDistribution"

    case fill
    case fillEqually
    case fillProportionaly
    case equalCentering
    case equalSpacing

    public static let allValues: [LayoutDistribution] = [.fill, .fillEqually, .fillProportionaly, .equalCentering, .equalSpacing]
}

#if canImport(UIKit)
    import UIKit

    extension LayoutDistribution {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
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
