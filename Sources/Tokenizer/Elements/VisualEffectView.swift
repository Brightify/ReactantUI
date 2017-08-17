import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class VisualEffectView: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.visualEffectView.allProperties
    }

    public class override var runtimeType: String {
        return "UIVisualEffectView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIVisualEffectView()
    }
    #endif
}
