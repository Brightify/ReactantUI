import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Toolbar: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "isTranslucent", key: "translucent", type: Bool.self),
            assignable(name: "barStyle", type: BarStyle.self),
            assignable(name: "barTintColor", type: UIColorPropertyType.self),
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
