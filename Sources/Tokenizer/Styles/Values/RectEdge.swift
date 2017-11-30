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
        return text.components(separatedBy: CharacterSet.whitespacesAndNewlines).flatMap(RectEdge.init)
    }

    public static func toGeneratedString(_ array: [RectEdge]) -> String {
        return "[\(array.map { "UIRectEdge.\($0.rawValue)" }.joined(separator: ", "))]"
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
