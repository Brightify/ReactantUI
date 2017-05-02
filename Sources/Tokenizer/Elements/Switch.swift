import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Switch: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "isOn", type: .bool),
            assignable(name: "onTintColor", type: .color(.uiColor)),
            assignable(name: "thumbTintColor", type: .color(.uiColor)),
            assignable(name: "onImage", type: .image),
            assignable(name: "offImage", type: .image),
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UISwitch"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UISwitch()
    }
    #endif
}
