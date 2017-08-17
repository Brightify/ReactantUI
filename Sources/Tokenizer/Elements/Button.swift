import Foundation

#if ReactantRuntime
import UIKit
#endif

public class Button: Container {

    override class var availableProperties: [PropertyDescription] {
        return Properties.button.allProperties
    }
    
    public class override var runtimeType: String {
        return "UIButton"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIButton()
    }
    #endif
}
