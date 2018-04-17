//
//  ProgressViewStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 16/04/2018.
//

import Foundation

public enum ProgressViewStyle: String, EnumPropertyType {
    public static let enumName = "UIProgressViewStyle"

    case `default`
    case bar

    static var allValues: [ProgressViewStyle] = [.default, .bar]

    public static var xsdType: XSDType {
        let values = Set(ProgressViewStyle.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: ProgressViewStyle.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
import UIKit

extension ProgressViewStyle {

    public var runtimeValue: Any? {
        switch self {
        case .default:
            return UIProgressViewStyle.default.rawValue
        case .bar:
            return UIProgressViewStyle.bar.rawValue
        }
    }
}
#endif
