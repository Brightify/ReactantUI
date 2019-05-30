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
}

#if canImport(UIKit)
import Hyperdrive

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
