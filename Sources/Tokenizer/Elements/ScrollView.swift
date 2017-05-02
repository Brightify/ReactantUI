import Foundation

#if ReactantRuntime
import UIKit
#endif

public class ScrollView: Container {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "contentOffset", type: .point),
            assignable(name: "contentSize", type: .size),
            assignable(name: "contentInset", type: .edgeInsets),
            assignable(name: "isScrollEnabled", key: "scrollEnabled", type: .bool),
            assignable(name: "isDirectionalLockEnabled", key: "directionalLockEnabled", type: .bool),
            assignable(name: "isPagingEnabled", key: "pagingEnabled", type: .bool),
            assignable(name: "bounces", type: .bool),
            assignable(name: "alwaysBounceVertical", type: .bool),
            assignable(name: "alwaysBounceHorizontal", type: .bool),
            assignable(name: "delaysContentTouches", type: .bool),
            assignable(name: "decelerationRate", type: .float),
            assignable(name: "scrollIndicatorInsets", type: .edgeInsets),
            assignable(name: "showsHorizontalScrollIndicator", type: .bool),
            assignable(name: "showsVerticalScrollIndicator", type: .bool),
            assignable(name: "zoomScale", type: .float),
            assignable(name: "maximumZoomScale", type: .float),
            assignable(name: "minimumZoomScale", type: .float),
            assignable(name: "bouncesZoom", type: .bool),
            assignable(name: "indicatorStyle", type: .scrollViewIndicatorStyle)
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
