import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class VisualEffectView: Container {

    public static let effect = assignable(name: "effect", type: VisualEffect.self)
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.visualEffectView.allProperties
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

