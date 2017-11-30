//
//  TabBar.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class TabBar: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.tabBar.allProperties
    }

    public class override var runtimeType: String {
        return "UITabBar"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UITabBar()
    }
    #endif
}

public class TabBarProperties: ViewProperties {
    public let isTranslucent: AssignablePropertyDescription<Bool>
    public let barStyle: AssignablePropertyDescription<BarStyle>
    public let barTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let itemSpacing: AssignablePropertyDescription<Float>
    public let itemWidth: AssignablePropertyDescription<Float>
    public let backgroundImage: AssignablePropertyDescription<Image>
    public let shadowImage: AssignablePropertyDescription<Image>
    public let selectionIndicatorImage: AssignablePropertyDescription<Image>
    
    public required init(configuration: Configuration) {
        isTranslucent = configuration.property(name: "isTranslucent", key: "translucent")
        barStyle = configuration.property(name: "barStyle")
        barTintColor = configuration.property(name: "barTintColor")
        itemSpacing = configuration.property(name: "itemSpacing")
        itemWidth = configuration.property(name: "itemWidth")
        backgroundImage = configuration.property(name: "backgroundImage")
        shadowImage = configuration.property(name: "shadowImage")
        selectionIndicatorImage = configuration.property(name: "selectionIndicatorImage")
        
        super.init(configuration: configuration)
    }
}
    
