//
//  ReturnKeyType.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 20/06/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ReturnKeyType: String, EnumPropertyType {
    public static let enumName = "UIReturnKeyType"

    case `default`
    case go
    case google
    case join
    case next
    case route
    case search
    case send
    case yahoo
    case done
    case emergencyCall
    case `continue`
}

#if ReactantRuntime
    import UIKit

    extension ReturnKeyType {

        public var runtimeValue: Any? {
            switch self {
            case .`default`:
                return UIReturnKeyType.default.rawValue
            case .go:
                return UIReturnKeyType.go.rawValue
            case .google:
                return UIReturnKeyType.google.rawValue
            case .join:
                return UIReturnKeyType.join.rawValue
            case .next:
                return UIReturnKeyType.next.rawValue
            case .route:
                return UIReturnKeyType.route.rawValue
            case .search:
                return UIReturnKeyType.search.rawValue
            case .send:
                return UIReturnKeyType.send.rawValue
            case .yahoo:
                return UIReturnKeyType.yahoo.rawValue
            case .done:
                return UIReturnKeyType.done.rawValue
            case .emergencyCall:
                return UIReturnKeyType.emergencyCall.rawValue
            case .`continue`:
                return UIReturnKeyType.continue.rawValue
            }
        }
    }
#endif
