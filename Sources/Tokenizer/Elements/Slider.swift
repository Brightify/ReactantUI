import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Slider: View {
    
    public static let value = assignable(name: "value", type: Float.self)
    public static let minimumValue = assignable(name: "minimumValue", type: Float.self)
    public static let maximumValue = assignable(name: "maximumValue", type: Float.self)
    public static let isContinuous = assignable(name: "isContinuous", key: "continuous", type: Bool.self)
    public static let minimumValueImage = assignable(name: "minimumValueImage", type: Image.self)
    public static let maximumValueImage = assignable(name: "maximumValueImage", type: Image.self)
    public static let minimumTrackTintColor = assignable(name: "minimumTrackTintColor", type: UIColorPropertyType.self)
    public static let currentMinimumTrackImage = assignable(name: "currentMinimumTrackImage", type: Image.self)
    public static let maximumTrackTintColor = assignable(name: "maximumTrackTintColor", type: UIColorPropertyType.self)
    public static let currentMaximumTrackImage = assignable(name: "currentMaximumTrackImage", type: Image.self)
    public static let thumbTintColor = assignable(name: "thumbTintColor", type: UIColorPropertyType.self)
    public static let currentThumbImage = assignable(name: "currentThumbImage", type: Image.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            value,
            minimumValue,
            maximumValue,
            isContinuous,
            minimumValueImage,
            maximumValueImage,
            minimumTrackTintColor,
            currentMinimumTrackImage,
            maximumTrackTintColor,
            currentMaximumTrackImage,
            thumbTintColor,
            currentThumbImage,
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
