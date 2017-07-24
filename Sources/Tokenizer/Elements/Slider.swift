import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Slider: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "value", type: Float.self),
            assignable(name: "minimumValue", type: Float.self),
            assignable(name: "maximumValue", type: Float.self),
            assignable(name: "isContinuous", key: "continuous", type: Bool.self),
            assignable(name: "minimumValueImage", type: Image.self),
            assignable(name: "maximumValueImage", type: Image.self),
            assignable(name: "minimumTrackTintColor", type: UIColorPropertyType.self),
            assignable(name: "currentMinimumTrackImage", type: Image.self),
            assignable(name: "maximumTrackTintColor", type: UIColorPropertyType.self),
            assignable(name: "currentMaximumTrackImage", type: Image.self),
            assignable(name: "thumbTintColor", type: UIColorPropertyType.self),
            assignable(name: "currentThumbImage", type: Image.self),
            ] + super.availableProperties
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
