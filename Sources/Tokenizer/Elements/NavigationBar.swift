import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class NavigationBar: View {
    public static let barTintColor = assignable(name: "barTintColor", type: UIColorPropertyType.self)
    public static let backIndicatorImage = assignable(name: "backIndicatorImage", type: Image.self)
    public static let backIndicatorTransitionMaskImage = assignable(name: "backIndicatorTransitionMaskImage", type: Image.self)
    public static let shadowImage = assignable(name: "shadowImage", type: Image.self)
    public static let isTranslucent = assignable(name: "isTranslucent", key: "translucent", type: Bool.self)
    public static let barStyle = assignable(name: "barStyle", type: BarStyle.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            barTintColor,
            backIndicatorImage,
            backIndicatorTransitionMaskImage,
            shadowImage,
            isTranslucent,
            barStyle,
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
