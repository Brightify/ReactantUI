import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class PageControl: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.pageControl.allProperties
    }

    public class override var runtimeType: String {
        return "UIPageControl"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIPageControl()
    }
    #endif
}
