//
//  ConstraintPriority.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ConstraintPriority {
    case required
    case high
    case medium
    case low
    case custom(Double)

    public var numeric: Double {
        switch self {
        case .required:
            return 1000.0
        case .high:
            return 750.0
        case .medium:
            return 500.0
        case .low:
            return 250.0
        case .custom(let value):
            return value
        }
    }

    public init(numericValue: Double) {
        switch numericValue {
        case ConstraintPriority.required.numeric:
            self = .required
        case ConstraintPriority.high.numeric:
            self = .high
        case ConstraintPriority.medium.numeric:
            self = .medium
        case ConstraintPriority.low.numeric:
            self = .low
        default:
            self = .custom(numericValue)
        }
    }

    public init(_ value: String) throws {
        switch value {
        case "required":
            self.init(numericValue: ConstraintPriority.required.numeric)
        case "high":
            self.init(numericValue: ConstraintPriority.high.numeric)
        case "medium":
            self.init(numericValue: ConstraintPriority.medium.numeric)
        case "low":
            self.init(numericValue: ConstraintPriority.low.numeric)
        default:
            guard let doubleValue = Double(value) else {
                throw TokenizationError(message: "Unknown constraint priority \(value)")
            }
            self.init(numericValue: doubleValue)
        }
    }
}

extension ConstraintPriority: XMLAttributeDeserializable {
    public static func deserialize(_ attribute: XMLAttribute) throws -> ConstraintPriority {
        return try ConstraintPriority(attribute.text)
    }
}
