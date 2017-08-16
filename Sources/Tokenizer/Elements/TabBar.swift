import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class TabBar: View {
    
    public static let isTranslucent = assignable(name: "isTranslucent", key: "translucent", type: Bool.self)
    public static let barStyle = assignable(name: "barStyle", type: BarStyle.self)
    public static let barTintColor = assignable(name: "barTintColor", type: UIColorPropertyType.self)
    public static let itemSpacing = assignable(name: "itemSpacing", type: Float.self)
    public static let itemWidth = assignable(name: "itemWidth", type: Float.self)
    public static let backgroundImage = assignable(name: "backgroundImage", type: Image.self)
    public static let shadowImage = assignable(name: "shadowImage", type: Image.self)
    public static let selectionIndicatorImage = assignable(name: "selectionIndicatorImage", type: Image.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            isTranslucent,
            barStyle,
            barTintColor,
            itemSpacing,
            itemWidth,
            backgroundImage,
            shadowImage,
            selectionIndicatorImage,
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
