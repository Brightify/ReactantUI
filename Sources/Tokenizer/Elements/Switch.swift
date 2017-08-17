import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Switch: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.switch.allProperties
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
