//
//  PageControl.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class PageControl: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.pageControl.allProperties
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

public class PageControlProperties: ViewProperties {
    public let currentPage: AssignablePropertyDescription<Int>
    public let numberOfPages: AssignablePropertyDescription<Int>
    public let hidesForSinglePage: AssignablePropertyDescription<Bool>
    public let pageIndicatorTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let currentPageIndicatorTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let defersCurrentPageDisplay: AssignablePropertyDescription<Bool>
    
    public required init(configuration: Configuration) {
        currentPage = configuration.property(name: "currentPage")
        numberOfPages = configuration.property(name: "numberOfPages")
        hidesForSinglePage = configuration.property(name: "hidesForSinglePage")
        pageIndicatorTintColor = configuration.property(name: "pageIndicatorTintColor")
        currentPageIndicatorTintColor = configuration.property(name: "currentPageIndicatorTintColor")
        defersCurrentPageDisplay = configuration.property(name: "defersCurrentPageDisplay")
        
        super.init(configuration: configuration)
    }
}
