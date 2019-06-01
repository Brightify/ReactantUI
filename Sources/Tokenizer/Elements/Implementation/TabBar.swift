//
//  TabBar.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class TabBar: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.tabBar.allProperties
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return UITabBar()
    }
    #endif
}

public class TabBarProperties: ViewProperties {
    public let isTranslucent: AssignablePropertyDescription<Bool>
    public let barStyle: AssignablePropertyDescription<BarStyle>
    public let barTintColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let itemSpacing: AssignablePropertyDescription<Double>
    public let itemWidth: AssignablePropertyDescription<Double>
    public let backgroundImage: AssignablePropertyDescription<Image?>
    public let shadowImage: AssignablePropertyDescription<Image?>
    public let selectionIndicatorImage: AssignablePropertyDescription<Image?>
    
    public required init(configuration: Configuration) {
        isTranslucent = configuration.property(name: "isTranslucent", key: "translucent", defaultValue: true)
        barStyle = configuration.property(name: "barStyle", defaultValue: .default)
        barTintColor = configuration.property(name: "barTintColor")
        itemSpacing = configuration.property(name: "itemSpacing")
        itemWidth = configuration.property(name: "itemWidth")
        backgroundImage = configuration.property(name: "backgroundImage")
        shadowImage = configuration.property(name: "shadowImage")
        selectionIndicatorImage = configuration.property(name: "selectionIndicatorImage")
        
        super.init(configuration: configuration)
    }
}
    
