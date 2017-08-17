import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class TextView: View {
    override class var availableProperties: [PropertyDescription] {
        return Properties.textView.allProperties
    }

    public class override var runtimeType: String {
        return "UITextView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UITextView()
    }
    #endif
}
