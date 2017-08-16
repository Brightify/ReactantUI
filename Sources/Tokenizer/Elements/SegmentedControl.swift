import Foundation

#if ReactantRuntime
    import UIKit
#endif

// TODO add a way of adding segments
public class SegmentedControl: View {
    
    public static let selectedSegmentIndex = assignable(name: "selectedSegmentIndex", type: Int.self)
    public static let isMomentary = assignable(name: "isMomentary", type: Bool.self)
    public static let apportionsSegmentWidthsByContent = assignable(name: "apportionsSegmentWidthsByContent", type: Bool.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            selectedSegmentIndex,
            isMomentary,
            apportionsSegmentWidthsByContent,
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
