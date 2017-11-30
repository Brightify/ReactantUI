//
//  Toolbar.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Toolbar: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.toolbar.allProperties
    }

    public class override var runtimeType: String {
        return "UIToolbar"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIToolbar()
    }
    #endif
}

public class ToolbarProperties: ViewProperties {
    public let isTranslucent: AssignablePropertyDescription<Bool>
    public let barStyle: AssignablePropertyDescription<BarStyle>
    public let barTintColor: AssignablePropertyDescription<UIColorPropertyType>
    
    public required init(configuration: Configuration) {
        isTranslucent = configuration.property(name: "isTranslucent", key: "translucent")
        barStyle = configuration.property(name: "barStyle")
        barTintColor = configuration.property(name: "barTintColor")
        
        super.init(configuration: configuration)
    }
}
