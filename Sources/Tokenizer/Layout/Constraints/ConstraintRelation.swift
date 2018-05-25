//
//  ConstraintRelation.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ConstraintRelation: CustomStringConvertible {
    case equal
    case lessThanOrEqual
    case greaterThanOrEqual

    public var description: String {
        switch self {
        case .equal:
            return "equalTo"
        case .lessThanOrEqual:
            return "lessThanOrEqualTo"
        case .greaterThanOrEqual:
            return "greaterThanOrEqualTo"
        }
    }

    init(_ string: String) throws {
        switch string {
        case "equal", "eq":
            self = .equal
        case "lessOrEqual", "lte", "lt":
            self = .lessThanOrEqual
        case "greaterOrEqual", "gte", "gt":
            self = .greaterThanOrEqual
        default:
            throw TokenizationError(message: "Unknown relation \(string)")
        }
    }
}
