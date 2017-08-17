import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Toolbar: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.toolbar.allProperties
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
