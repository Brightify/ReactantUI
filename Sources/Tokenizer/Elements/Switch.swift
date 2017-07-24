import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Switch: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "isOn", type: Bool.self),
            assignable(name: "onTintColor", type: UIColorPropertyType.self),
            assignable(name: "thumbTintColor", type: UIColorPropertyType.self),
            assignable(name: "onImage", type: Image.self),
            assignable(name: "offImage", type: Image.self),
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
