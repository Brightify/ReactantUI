import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Toolbar: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "isTranslucent", key: "translucent", type: .bool),
            assignable(name: "barStyle", type: .barStyle),
            assignable(name: "barTintColor", type: .color(.uiColor)),
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UIToolbar"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIToolbar()
    }
    #endif
}
