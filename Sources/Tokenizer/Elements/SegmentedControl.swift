import Foundation

#if ReactantRuntime
    import UIKit
#endif

// TODO add a way of adding segments
public class SegmentedControl: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "selectedSegmentIndex", type: Int.self),
            assignable(name: "isMomentary", type: Bool.self),
            assignable(name: "apportionsSegmentWidthsByContent", type: Bool.self),
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UISegmentedControl"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UISegmentedControl()
    }
    #endif
}
