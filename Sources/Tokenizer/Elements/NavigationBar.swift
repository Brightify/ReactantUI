import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class NavigationBar: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "barTintColor", type: UIColorPropertyType.self),
            assignable(name: "backIndicatorImage", type: Image.self),
            assignable(name: "backIndicatorTransitionMaskImage", type: Image.self),
            assignable(name: "shadowImage", type: Image.self),
            assignable(name: "isTranslucent", key: "translucent", type: Bool.self),
            assignable(name: "barStyle", type: BarStyle.self),
            // FIXME add backgroundImage
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UINavigationBar"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UINavigationBar()
    }
    #endif
}
