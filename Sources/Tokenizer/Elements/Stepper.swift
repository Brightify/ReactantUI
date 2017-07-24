import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Stepper: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "value", type: Double.self),
            assignable(name: "minimumValue", type: Double.self),
            assignable(name: "maximumValue", type: Double.self),
            assignable(name: "stepValue", type: Double.self),
            assignable(name: "isContinuous", key: "continuous", type: Bool.self),
            assignable(name: "autorepeat", type: Bool.self),
            assignable(name: "wraps", type: Bool.self),
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
