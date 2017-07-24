import Foundation

#if ReactantRuntime
import UIKit
#endif

public class ScrollView: Container {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "contentOffset", type: Point.self),
            assignable(name: "contentSize", type: Size.self),
            assignable(name: "contentInset", type: EdgeInsets.self),
            assignable(name: "isScrollEnabled", key: "scrollEnabled", type: Bool.self),
            assignable(name: "isDirectionalLockEnabled", key: "directionalLockEnabled", type: Bool.self),
            assignable(name: "isPagingEnabled", key: "pagingEnabled", type: Bool.self),
            assignable(name: "bounces", type: Bool.self),
            assignable(name: "alwaysBounceVertical", type: Bool.self),
            assignable(name: "alwaysBounceHorizontal", type: Bool.self),
            assignable(name: "delaysContentTouches", type: Bool.self),
            assignable(name: "decelerationRate", type: Float.self),
            assignable(name: "scrollIndicatorInsets", type: EdgeInsets.self),
            assignable(name: "showsHorizontalScrollIndicator", type: Bool.self),
            assignable(name: "showsVerticalScrollIndicator", type: Bool.self),
            assignable(name: "zoomScale", type: Float.self),
            assignable(name: "maximumZoomScale", type: Float.self),
            assignable(name: "minimumZoomScale", type: Float.self),
            assignable(name: "bouncesZoom", type: Bool.self),
            assignable(name: "indicatorStyle", type: ScrollViewIndicatorStyle.self)
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UIScrollView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIScrollView()
    }
    #endif
}
