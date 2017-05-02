import Foundation


public struct Constraint {
    public let field: String?
    public let anchor: LayoutAnchor
    public let type: ConstraintType
    public let relation: ConstraintRelation
    public let priority: ConstraintPriority

    public static func constraints(name: String, attribute: XMLAttribute) throws -> [Constraint] {
        let layoutAttributes = try LayoutAttribute.deserialize(name)
        let tokens = Lexer.tokenize(input: attribute.text)
        return try layoutAttributes.flatMap { try ConstraintParser(tokens: tokens, layoutAttribute: $0).parse() }
    }
}

public enum ConstraintType {
    case constant(Float)
    case targeted(target: ConstraintTarget, targetAnchor: LayoutAnchor, multiplier: Float, constant: Float)
}

public enum ConstraintTarget {
    case field(String)
    case layoutId(String)
    case parent
    case this
}
