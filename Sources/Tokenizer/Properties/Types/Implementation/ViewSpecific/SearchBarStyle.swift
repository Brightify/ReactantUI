//
//  SearchBarStyle.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum SearchBarStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UISearchBarStyle"

    case `default`
    case minimal
    case prominent

    public static let allValues: [SearchBarStyle] = [.`default`, .minimal, .prominent]
}

#if canImport(UIKit)
    import UIKit

    extension SearchBarStyle {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .`default`:
                return UISearchBar.Style.default.rawValue
            case .minimal:
                return UISearchBar.Style.minimal.rawValue
            case .prominent:
                return UISearchBar.Style.prominent.rawValue
            }
        }
    }
#endif
