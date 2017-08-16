import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Switch: View {
    
    public static let isOn = assignable(name: "isOn", type: Bool.self)
    public static let onTintColor = assignable(name: "onTintColor", type: UIColorPropertyType.self)
    public static let thumbTintColor = assignable(name: "thumbTintColor", type: UIColorPropertyType.self)
    public static let onImage = assignable(name: "onImage", type: Image.self)
    public static let offImage = assignable(name: "offImage", type: Image.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            isOn,
            onTintColor,
            thumbTintColor,
            onImage,
            offImage,
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
