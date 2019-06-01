//
//  ScrollView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class ScrollView: Container {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.scrollView.allProperties
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return UIScrollView()
    }
    #endif
}

public class ScrollViewProperties: ViewProperties {
    public let contentOffset: AssignablePropertyDescription<Point>
    public let contentSize: AssignablePropertyDescription<Size>
    public let contentInset: AssignablePropertyDescription<EdgeInsets>
    public let isScrollEnabled: AssignablePropertyDescription<Bool>
    public let isDirectionalLockEnabled: AssignablePropertyDescription<Bool>
    public let isPagingEnabled: AssignablePropertyDescription<Bool>
    public let bounces: AssignablePropertyDescription<Bool>
    public let alwaysBounceVertical: AssignablePropertyDescription<Bool>
    public let alwaysBounceHorizontal: AssignablePropertyDescription<Bool>
    public let delaysContentTouches: AssignablePropertyDescription<Bool>
    #warning("TODO Add a `ScrollViewDecelerationRate` type that'll have `default` so we dn't have to say exactly `0.998`.")
    public let decelerationRate: AssignablePropertyDescription<Double>
    public let scrollIndicatorInsets: AssignablePropertyDescription<EdgeInsets>
    public let showsHorizontalScrollIndicator: AssignablePropertyDescription<Bool>
    public let showsVerticalScrollIndicator: AssignablePropertyDescription<Bool>
    public let zoomScale: AssignablePropertyDescription<Double>
    public let maximumZoomScale: AssignablePropertyDescription<Double>
    public let minimumZoomScale: AssignablePropertyDescription<Double>
    public let bouncesZoom: AssignablePropertyDescription<Bool>
    public let indicatorStyle: AssignablePropertyDescription<ScrollViewIndicatorStyle>
    
    public required init(configuration: Configuration) {
        contentOffset = configuration.property(name: "contentOffset", defaultValue: .zero)
        contentSize = configuration.property(name: "contentSize", defaultValue: .zero)
        contentInset = configuration.property(name: "contentInset", defaultValue: .zero)
        isScrollEnabled = configuration.property(name: "isScrollEnabled", key: "scrollEnabled", defaultValue: true)
        isDirectionalLockEnabled = configuration.property(name: "isDirectionalLockEnabled", key: "directionalLockEnabled")
        isPagingEnabled = configuration.property(name: "isPagingEnabled", key: "pagingEnabled")
        bounces = configuration.property(name: "bounces", defaultValue: true)
        alwaysBounceVertical = configuration.property(name: "alwaysBounceVertical")
        alwaysBounceHorizontal = configuration.property(name: "alwaysBounceHorizontal")
        delaysContentTouches = configuration.property(name: "delaysContentTouches", defaultValue: true)
        decelerationRate = configuration.property(name: "decelerationRate", defaultValue: 0.998)
        scrollIndicatorInsets = configuration.property(name: "scrollIndicatorInsets", defaultValue: .zero)
        showsHorizontalScrollIndicator = configuration.property(name: "showsHorizontalScrollIndicator", defaultValue: true)
        showsVerticalScrollIndicator = configuration.property(name: "showsVerticalScrollIndicator", defaultValue: true)
        zoomScale = configuration.property(name: "zoomScale", defaultValue: 1)
        maximumZoomScale = configuration.property(name: "maximumZoomScale", defaultValue: 1)
        minimumZoomScale = configuration.property(name: "minimumZoomScale", defaultValue: 1)
        bouncesZoom = configuration.property(name: "bouncesZoom", defaultValue: true)
        indicatorStyle = configuration.property(name: "indicatorStyle", defaultValue: .default)
        
        super.init(configuration: configuration)
    }
}
    
