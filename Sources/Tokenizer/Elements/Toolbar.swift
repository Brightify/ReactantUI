import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Toolbar: View {
    
    public static let isTranslucent = assignable(name: "isTranslucent", key: "translucent", type: Bool.self)
    public static let barStyle = assignable(name: "barStyle", type: BarStyle.self)
    public static let barTintColor = assignable(name: "barTintColor", type: UIColorPropertyType.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            isTranslucent,
            barStyle,
            barTintColor,
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
