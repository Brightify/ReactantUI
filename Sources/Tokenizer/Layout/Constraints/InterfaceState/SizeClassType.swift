//
//  SizeClassType.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 03/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation

public enum SizeClassType {
    case horizontal
    case vertical

    var description: String {
        switch self {
        case .horizontal:
            return "horizontal"
        case .vertical:
            return "vertical"
        }
    }
}
