import Foundation

#if ReactantRuntime
import UIKit
#endif

public class ScrollView: Container {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.scrollView.allProperties
    }

    public class override var runtimeType: String {
        return "UIScrollView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIScrollView()
    }
    #endif
}
