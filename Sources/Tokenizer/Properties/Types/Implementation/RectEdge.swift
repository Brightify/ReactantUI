//
//  RectEdge.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum RectEdge: String {
    case top
    case left
    case bottom
    case right
    case all

    static func parse(text: String) -> [RectEdge] {
        return text.components(separatedBy: CharacterSet.whitespacesAndNewlines).compactMap(RectEdge.init)
    }

    public static func toGeneratedString(_ array: [RectEdge]) -> String {
        return "[\(array.map { "UIRectEdge.\($0.rawValue)" }.joined(separator: ", "))]"
    }

    static var allValues: [RectEdge] = [.top, .left, .bottom, .right, .all]

    public static var xsdType: XSDType {
        let values = Set(RectEdge.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: "UIRectEdge", base: .string, values: values))
    }
}


#if ReactantRuntime
import UIKit

extension RectEdge: OptionSetValue {
    var value: UIRectEdge {
        switch self {
        case .top:
            return .top
        case .left:
            return .left
        case .bottom:
            return .bottom
        case .right:
            return .right
        case .all:
            return .all
        }
    }
}
#endif
