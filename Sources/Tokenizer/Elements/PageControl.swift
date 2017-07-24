import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class PageControl: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "currentPage", type: Int.self),
            assignable(name: "numberOfPages", type: Int.self),
            assignable(name: "hidesForSinglePage", type: Bool.self),
            assignable(name: "pageIndicatorTintColor", type: UIColorPropertyType.self),
            assignable(name: "currentPageIndicatorTintColor", type: UIColorPropertyType.self),
            assignable(name: "defersCurrentPageDisplay", type: Bool.self),
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UIPageControl"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIPageControl()
    }
    #endif
}
