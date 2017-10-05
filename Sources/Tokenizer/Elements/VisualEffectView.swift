import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class VisualEffectView: Container {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "effect", type: .visualEffect),
            ] + super.availableProperties
    }

    public override var addSubviewMethod: String {
        return "contentView.addSubview"
    }

    public class override var runtimeType: String {
        return "UIVisualEffectView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIVisualEffectView()
    }

    public override func add(subview: UIView, toInstanceOfSelf: UIView) {
    guard let visualEffectView = toInstanceOfSelf as? UIVisualEffectView else {
    return super.add(subview: subview, toInstanceOfSelf: toInstanceOfSelf)
    }
    visualEffectView.contentView.addSubview(subview)
    }
    #endif
}

