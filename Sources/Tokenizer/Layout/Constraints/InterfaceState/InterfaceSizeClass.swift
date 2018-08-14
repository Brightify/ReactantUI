//
//  InterfaceSizeClass.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 03/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum InterfaceSizeClass {
    case compact
    case regular
    case unspecified

    var description: String {
        switch self {
        case .compact:
            return "compact"
        case .regular:
            return "regular"
        case .unspecified:
            return "unspecified"
        }
    }

    #if canImport(UIKit)
    var runtimeValue: UIUserInterfaceSizeClass {
        switch self {
        case .compact:
            return .compact
        case .regular:
            return .regular
        case .unspecified:
            return .unspecified
        }
    }
    #endif
}
