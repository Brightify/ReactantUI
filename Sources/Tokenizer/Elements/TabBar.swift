import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class TabBar: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.tabBar.allProperties
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
