import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Stepper: View {
    
    public static let value = assignable(name: "value", type: Double.self)
    public static let minimumValue = assignable(name: "minimumValue", type: Double.self)
    public static let maximumValue = assignable(name: "maximumValue", type: Double.self)
    public static let stepValue = assignable(name: "stepValue", type: Double.self)
    public static let isContinuous = assignable(name: "isContinuous", key: "continuous", type: Bool.self)
    public static let autorepeat = assignable(name: "autorepeat", type: Bool.self)
    public static let wraps = assignable(name: "wraps", type: Bool.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            value,
            minimumValue,
            maximumValue,
            stepValue,
            isContinuous,
            autorepeat,
            wraps,
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UIStepper"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIStepper()
    }
    #endif
}
