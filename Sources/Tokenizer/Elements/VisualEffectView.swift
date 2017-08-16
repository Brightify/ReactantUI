import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class VisualEffectView: View {
    
    public static let effect = assignable(name: "effect", type: VisualEffect.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            effect,
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UIVisualEffectView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIVisualEffectView()
    }
    #endif
}
