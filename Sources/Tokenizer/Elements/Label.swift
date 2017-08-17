import Foundation

#if ReactantRuntime
import UIKit
#endif

public class Label: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.label.allProperties
    }

    public class override var runtimeType: String {
        return "UILabel"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UILabel()
    }
    #endif
}
