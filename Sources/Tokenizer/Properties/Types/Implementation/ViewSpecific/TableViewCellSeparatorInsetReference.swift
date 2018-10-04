//
//  TableViewCellSeparatorInsetReference.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

public enum TableViewCellSeparatorInsetReference: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UITableViewSeparatorInsetReference"

    case fromCellEdges
    case fromAutomaticInsets
}

#if canImport(UIKit)
    import UIKit

    extension TableViewCellSeparatorInsetReference {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .fromCellEdges:
                if #available(iOS 11.0, tvOS 11.0, *) {
                    return UITableView.SeparatorInsetReference.fromCellEdges.rawValue
                }
                return nil
            case .fromAutomaticInsets:
                if #available(iOS 11.0, tvOS 11.0, *) {
                    return UITableView.SeparatorInsetReference.fromAutomaticInsets.rawValue
                }
                return nil
            }
        }
    }
#endif
