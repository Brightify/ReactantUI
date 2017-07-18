import Foundation
#if ReactantRuntime
import UIKit
#endif

public protocol UIElement: Assignable {
    var layout: Layout { get set }
    var properties: [Property] { get set }
    var styles: [String] { get set }

    static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }
    static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }

    var requiredImports: Set<String> { get }

    var initialization: String { get }

    #if ReactantRuntime
    func initialize() throws -> UIView
    #endif
}

extension UIElement {
    public static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (ConstraintPriority.high, ConstraintPriority.high)
    }
    public static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (ConstraintPriority.low, ConstraintPriority.low)
    }
}
