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
        case "lessOrEqual", "lt":
            self = .lessThanOrEqual
        case "greaterOrEqual", "gt":
            self = .greaterThanOrEqual
        default:
            throw TokenizationError(message: "Unknown relation \(string)")
        }
    }
}
