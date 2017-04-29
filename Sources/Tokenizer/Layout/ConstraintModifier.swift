import Foundation

public enum ConstraintModifier {
    case multiplied(by: Float)
    case divided(by: Float)
    case offset(by: Float)
    case inset(by: Float)
}
