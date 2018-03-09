//
//  SearchBarStyle.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum SearchBarStyle: String, EnumPropertyType {
    public static let enumName = "UISearchBarStyle"

    case `default`
    case minimal
    case prominent

    static var allValues: [SearchBarStyle] = [.`default`, .minimal, .prominent]

    public static var xsdType: XSDType {
        let values = Set(SearchBarStyle.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: SearchBarStyle.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
    import UIKit

    extension SearchBarStyle {

        public var runtimeValue: Any? {
            switch self {
            case .`default`:
                return UISearchBarStyle.default.rawValue
            case .minimal:
                return UISearchBarStyle.minimal.rawValue
            case .prominent:
                return UISearchBarStyle.prominent.rawValue
            }
        }
    }
#endif
