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

    static var allValues: [TableViewCellSeparatorInsetReference] = [.fromCellEdges, .fromAutomaticInsets]

    public static var xsdType: XSDType {
        let values = Set(TableViewCellSeparatorInsetReference.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: TableViewCellSeparatorInsetReference.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
    import UIKit

    extension TableViewCellSeparatorInsetReference {

        public var runtimeValue: Any? {
            switch self {
            case .fromCellEdges:
                if #available(iOS 11.0, tvOS 11.0, *) {
                    return UITableViewSeparatorInsetReference.fromCellEdges.rawValue
                }
                return nil
            case .fromAutomaticInsets:
                if #available(iOS 11.0, tvOS 11.0, *) {
                    return UITableViewSeparatorInsetReference.fromAutomaticInsets.rawValue
                }
                return nil
            }
        }
    }
#endif
