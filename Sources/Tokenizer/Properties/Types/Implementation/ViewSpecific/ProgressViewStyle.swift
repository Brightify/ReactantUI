//
//  ProgressViewStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 16/04/2018.
//

import Foundation

public enum ProgressViewStyle: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIProgressViewStyle"

    case `default`
    case bar
}

#if canImport(UIKit)
import UIKit

extension ProgressViewStyle {

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .default:
            return UIProgressView.Style.default.rawValue
        case .bar:
            return UIProgressView.Style.bar.rawValue
        }
    }
}
#endif
