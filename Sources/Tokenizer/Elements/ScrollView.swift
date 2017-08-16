import Foundation

#if ReactantRuntime
import UIKit
#endif

public class ScrollView: Container {
    
    public static let contentOffset = assignable(name: "contentOffset", type: Point.self)
    public static let contentSize = assignable(name: "contentSize", type: Size.self)
    public static let contentInset = assignable(name: "contentInset", type: EdgeInsets.self)
    public static let isScrollEnabled = assignable(name: "isScrollEnabled", key: "scrollEnabled", type: Bool.self)
    public static let isDirectionalLockEnabled = assignable(name: "isDirectionalLockEnabled", key: "directionalLockEnabled", type: Bool.self)
    public static let isPagingEnabled = assignable(name: "isPagingEnabled", key: "pagingEnabled", type: Bool.self)
    public static let bounces = assignable(name: "bounces", type: Bool.self)
    public static let alwaysBounceVertical = assignable(name: "alwaysBounceVertical", type: Bool.self)
    public static let alwaysBounceHorizontal = assignable(name: "alwaysBounceHorizontal", type: Bool.self)
    public static let delaysContentTouches = assignable(name: "delaysContentTouches", type: Bool.self)
    public static let decelerationRate = assignable(name: "decelerationRate", type: Float.self)
    public static let scrollIndicatorInsets = assignable(name: "scrollIndicatorInsets", type: EdgeInsets.self)
    public static let showsHorizontalScrollIndicator = assignable(name: "showsHorizontalScrollIndicator", type: Bool.self)
    public static let showsVerticalScrollIndicator = assignable(name: "showsVerticalScrollIndicator", type: Bool.self)
    public static let zoomScale = assignable(name: "zoomScale", type: Float.self)
    public static let maximumZoomScale = assignable(name: "maximumZoomScale", type: Float.self)
    public static let minimumZoomScale = assignable(name: "minimumZoomScale", type: Float.self)
    public static let bouncesZoom = assignable(name: "bouncesZoom", type: Bool.self)
    public static let indicatorStyle = assignable(name: "indicatorStyle", type: ScrollViewIndicatorStyle.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            contentOffset,
            contentSize,
            contentInset,
            isScrollEnabled,
            isDirectionalLockEnabled,
            isPagingEnabled,
            bounces,
            alwaysBounceVertical,
            alwaysBounceHorizontal,
            delaysContentTouches,
            decelerationRate,
            scrollIndicatorInsets,
            showsHorizontalScrollIndicator,
            showsVerticalScrollIndicator,
            zoomScale,
            maximumZoomScale,
            minimumZoomScale,
            bouncesZoom,
            indicatorStyle,
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
