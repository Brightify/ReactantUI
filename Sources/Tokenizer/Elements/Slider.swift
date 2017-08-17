import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Slider: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.slider.allProperties
    }

    public class override var runtimeType: String {
        return "UISlider"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UISlider()
    }
    #endif
}
