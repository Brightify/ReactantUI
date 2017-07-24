import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class ActivityIndicatorElement: View {
    public static let color = assignable(name: "color", type: UIColorPropertyType.self)
    public static let hidesWhenStopped = assignable(name: "hidesWhenStopped", type: Bool.self)
    public static let indicatorStyle = assignable(name: "indicatorStyle", swiftName: "activityIndicatorViewStyle", key: "activityIndicatorViewStyle", type: ActivityIndicatorStyle.self)

    override class var availableProperties: [PropertyDescription] {
        return [
                color,
                hidesWhenStopped,
                indicatorStyle,
            ] + super.availableProperties
    }

    public static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (.high, .high)
    }

    public class override var runtimeType: String {
        return "UIActivityIndicatorView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIActivityIndicatorView()
    }
    #endif
}
