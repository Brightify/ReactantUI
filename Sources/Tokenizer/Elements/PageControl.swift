import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class PageControl: View {
    
    public static let currentPage = assignable(name: "currentPage", type: Int.self)
    public static let numberOfPages = assignable(name: "numberOfPages", type: Int.self)
    public static let hidesForSinglePage = assignable(name: "hidesForSinglePage", type: Bool.self)
    public static let pageIndicatorTintColor = assignable(name: "pageIndicatorTintColor", type: UIColorPropertyType.self)
    public static let currentPageIndicatorTintColor = assignable(name: "currentPageIndicatorTintColor", type: UIColorPropertyType.self)
    public static let defersCurrentPageDisplay = assignable(name: "defersCurrentPageDisplay", type: Bool.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            currentPage,
            numberOfPages,
            hidesForSinglePage,
            pageIndicatorTintColor,
            currentPageIndicatorTintColor,
            defersCurrentPageDisplay,
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
