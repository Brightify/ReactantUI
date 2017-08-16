import Foundation


public enum ConstraintPriority {
    case required
    case high
    case medium
    case low
    case custom(Float)

    public var numeric: Float {
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

    public init(_ value: String) throws {
        switch value {
        case "required":
            self = .required
        case "high":
            self = .high
        case "medium":
            self = .medium
        case "low":
            self = .low
        default:
            throw TokenizationError(message: "Unknown constraint priority \(value)")
        }
    }
    
    public init(numericValue: Float) {
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
}

extension ConstraintPriority: XMLAttributeDeserializable {
    public static func deserialize(_ attribute: XMLAttribute) throws -> ConstraintPriority {
        return try ConstraintPriority(attribute.text)
    }
}
