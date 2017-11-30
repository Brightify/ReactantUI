//
//  ControlState.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum ControlState: String {
    case normal
    case highlighted
    case disabled
    case selected
    case focused

    public init?(rawValue: String) {
        switch rawValue {
        case "normal":
            self = .normal
        case "highlighted":
            self = .highlighted
        case "disabled":
            self = .disabled
        case "selected":
            self = .selected
        case "focused":
            self = .focused
        default:
            return nil
        }
    }
}

extension Array where Element == ControlState {
    var name: String {
        return flatMap { $0.rawValue }.joined(separator: ".")
    }
}

#if ReactantRuntime
import UIKit

extension ControlState: OptionSetValue {
    var value: UIControlState {
        switch self {
        case .normal:
            return .normal
        case .highlighted:
            return .highlighted
        case .disabled:
            return .disabled
        case .selected:
            return .selected
        case .focused:
            return .focused
        }
    }
}
#endif
