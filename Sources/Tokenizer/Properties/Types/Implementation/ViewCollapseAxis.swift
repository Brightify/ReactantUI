//
//  ViewCollapseAxis.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 09/08/2018.
//

import Foundation

public enum ViewCollapseAxis: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "CollapseAxis"

    case horizontal
    case vertical
    case both

    public static var allValues: [ViewCollapseAxis] = [.horizontal, .vertical, .both]

    public static var runtimeType: String = "Reactant.CollapseAxis"

    public static var xsdType: XSDType {
        let values = Set(ViewCollapseAxis.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: ViewCollapseAxis.enumName, base: .string, values: values))
    }
}

#if canImport(UIKit)
import Reactant

extension ViewCollapseAxis {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .both:
            return CollapseAxis.both.rawValue
        case .horizontal:
            return CollapseAxis.horizontal.rawValue
        case .vertical:
            return CollapseAxis.vertical.rawValue
        }
    }
}
#endif
