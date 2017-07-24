import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class TabBar: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "isTranslucent", key: "translucent", type: Bool.self),
            assignable(name: "barStyle", type: BarStyle.self),
            assignable(name: "barTintColor", type: UIColorPropertyType.self),
            assignable(name: "itemSpacing", type: Float.self),
            assignable(name: "itemWidth", type: Float.self),
            assignable(name: "backgroundImage", type: Image.self),
            assignable(name: "shadowImage", type: Image.self),
            assignable(name: "selectionIndicatorImage", type: Image.self),
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UITabBar"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UITabBar()
    }
    #endif
}
