//
//  DimensionType.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 03/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation

public enum DimensionType {
    case width
    case height

    var description: String {
        switch self {
        case .width:
            return "width"
        case .height:
            return "height"
        }
    }
}
