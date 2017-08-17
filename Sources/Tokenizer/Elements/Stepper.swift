import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Stepper: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.stepper.allProperties
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
