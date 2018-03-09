//
//  TableViewCellSeparatorInsetReference.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

public enum TableViewCellSeparatorInsetReference: String, EnumPropertyType {
    public static let enumName = "UITableViewSeparatorInsetReference"

    case fromCellEdges
    case fromAutomaticInsets
}

#if ReactantRuntime
    import UIKit

    extension TableViewCellSeparatorInsetReference {

        public var runtimeValue: Any? {
            switch self {
            case .fromCellEdges:
                if #available(iOS 11.0, *) {
                    return UITableViewSeparatorInsetReference.fromCellEdges.rawValue
                }
                return nil
            case .fromAutomaticInsets:
                if #available(iOS 11.0, *) {
                    return UITableViewSeparatorInsetReference.fromAutomaticInsets.rawValue
                }
                return nil
            }
        }
    }
#endif
