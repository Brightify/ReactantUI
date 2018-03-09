//
//  TableViewCellSeparatorStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

public enum TableViewCellSeparatorStyle: String, EnumPropertyType {
    public static let enumName = "UITableViewCellSeparatorStyle"

    case none
    case singleLine
}

#if ReactantRuntime
    import UIKit

    extension TableViewCellSeparatorStyle {

        public var runtimeValue: Any? {
            switch self {
            case .none:
                return UITableViewCellSeparatorStyle.none.rawValue
            case .singleLine:
                return UITableViewCellSeparatorStyle.singleLine.rawValue
            }
        }
    }
#endif
