//
//  LayoutDistribution.swift
//  Reactant
//
//  Created by Matouš Hýbl on 4/9/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum LayoutDistribution: String {
    case fill
    case fillEqually
    case fillProportionaly
    case equalCentering
    case equalSpacing
}

#if ReactantRuntime
    import UIKit

    extension LayoutDistribution: Appliable {

        public var value: Any? {
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
                return UIStackViewDistribution.fillProportionally
            }
        }
    }
#endif
