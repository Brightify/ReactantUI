//
//  TableViewCellSeparatorStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

public enum TableViewCellSeparatorStyle: String, EnumPropertyType, AttributeSupportedPropertyType, CaseIterable {
    public static let enumName = "UITableViewCellSeparatorStyle"

    case none
    case singleLine
}

#if canImport(UIKit)
    import UIKit

    extension TableViewCellSeparatorStyle {
        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            #if os(iOS)
            switch self {
            case .none:
                return UITableViewCell.SeparatorStyle.none.rawValue
            case .singleLine:
                return UITableViewCell.SeparatorStyle.singleLine.rawValue
            }
            #else
                fatalError("UITableViewCellSeparatorStyle is not available on tvOS")
            #endif
        }
    }
#endif
