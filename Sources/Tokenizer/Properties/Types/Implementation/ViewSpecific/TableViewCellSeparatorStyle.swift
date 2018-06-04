//
//  TableViewCellSeparatorStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

public enum TableViewCellSeparatorStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UITableViewCellSeparatorStyle"

    case none
    case singleLine

    static var allValues: [TableViewCellSeparatorStyle] = [.none, .singleLine]

    public static var xsdType: XSDType {
        let values = Set(TableViewCellSeparatorStyle.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: TableViewCellSeparatorStyle.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
    import UIKit

    extension TableViewCellSeparatorStyle {
        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            #if os(iOS)
            switch self {
            case .none:
                return UITableViewCellSeparatorStyle.none.rawValue
            case .singleLine:
                return UITableViewCellSeparatorStyle.singleLine.rawValue
            }
            #else
                fatalError("UITableViewCellSeparatorStyle is not available on tvOS")
            #endif
        }
    }
#endif
