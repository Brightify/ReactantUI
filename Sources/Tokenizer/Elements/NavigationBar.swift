//
//  NavigationBar.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class NavigationBar: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.navigationBar.allProperties
    }

    public class override var runtimeType: String {
        return "UINavigationBar"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UINavigationBar()
    }
    #endif
}

public class NavigationBarProperties: ViewProperties {
    public let barTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let backIndicatorImage: AssignablePropertyDescription<Image>
    public let backIndicatorTransitionMaskImage: AssignablePropertyDescription<Image>
    public let shadowImage: AssignablePropertyDescription<Image>
    public let isTranslucent: AssignablePropertyDescription<Bool>
    public let barStyle: AssignablePropertyDescription<BarStyle>
    
    public required init(configuration: Configuration) {
        barTintColor = configuration.property(name: "barTintColor")
        backIndicatorImage = configuration.property(name: "backIndicatorImage")
        backIndicatorTransitionMaskImage = configuration.property(name: "backIndicatorTransitionMaskImage")
        shadowImage = configuration.property(name: "shadowImage")
        isTranslucent = configuration.property(name: "isTranslucent", key: "translucent")
        barStyle = configuration.property(name: "barStyle")
        
        super.init(configuration: configuration)
    }
}
