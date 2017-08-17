import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class NavigationBar: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.navigationBar.allProperties
    }

    public class override var runtimeType: String {
        return "UINavigationBar"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UINavigationBar()
    }
    #endif
}
