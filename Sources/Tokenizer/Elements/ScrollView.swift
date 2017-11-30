//
//  ScrollView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public class ScrollView: Container {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.scrollView.allProperties
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

public class ScrollViewProperties: ViewProperties {
    public let contentOffset: AssignablePropertyDescription<Point>
    public let contentSize: AssignablePropertyDescription<Size>
    public let contentInsets: AssignablePropertyDescription<EdgeInsets>
    public let isScrollEnabled: AssignablePropertyDescription<Bool>
    public let isDirectionalLockEnabled: AssignablePropertyDescription<Bool>
    public let isPagingEnabled: AssignablePropertyDescription<Bool>
    public let bounces: AssignablePropertyDescription<Bool>
    public let alwaysBounceVertical: AssignablePropertyDescription<Bool>
    public let alwaysBounceHorizontal: AssignablePropertyDescription<Bool>
    public let delaysContentTouches: AssignablePropertyDescription<Bool>
    public let decelerationRate: AssignablePropertyDescription<Float>
    public let scrollIndicatorInsets: AssignablePropertyDescription<EdgeInsets>
    public let showsHorizontalScrollIndicator: AssignablePropertyDescription<Bool>
    public let showsVerticalScrollIndicator: AssignablePropertyDescription<Bool>
    public let zoomScale: AssignablePropertyDescription<Float>
    public let maximumZoomScale: AssignablePropertyDescription<Float>
    public let minimumZoomScale: AssignablePropertyDescription<Float>
    public let bouncesZoom: AssignablePropertyDescription<Bool>
    public let indicatorStyle: AssignablePropertyDescription<ScrollViewIndicatorStyle>
    
    public required init(configuration: Configuration) {
        contentOffset = configuration.property(name: "contentOffset")
        contentSize = configuration.property(name: "contentSize")
        contentInsets = configuration.property(name: "contentInsets")
        isScrollEnabled = configuration.property(name: "isScrollEnabled", key: "scrollEnabled")
        isDirectionalLockEnabled = configuration.property(name: "isDirectionalLockEnabled", key: "directionalLockEnabled")
        isPagingEnabled = configuration.property(name: "isPagingEnabled", key: "pagingEnabled")
        bounces = configuration.property(name: "bounces")
        alwaysBounceVertical = configuration.property(name: "alwaysBounceVertical")
        alwaysBounceHorizontal = configuration.property(name: "alwaysBounceHorizontal")
        delaysContentTouches = configuration.property(name: "delaysContentTouches")
        decelerationRate = configuration.property(name: "decelerationRate")
        scrollIndicatorInsets = configuration.property(name: "scrollIndicatorInsets")
        showsHorizontalScrollIndicator = configuration.property(name: "showsHorizontalScrollIndicator")
        showsVerticalScrollIndicator = configuration.property(name: "showsVerticalScrollIndicator")
        zoomScale = configuration.property(name: "zoomScale")
        maximumZoomScale = configuration.property(name: "maximumZoomScale")
        minimumZoomScale = configuration.property(name: "minimumZoomScale")
        bouncesZoom = configuration.property(name: "bouncesZoom")
        indicatorStyle = configuration.property(name: "indicatorStyle")
        
        super.init(configuration: configuration)
    }
}
    
