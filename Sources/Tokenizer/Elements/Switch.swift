//
//  Switch.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Switch: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.switch.allProperties
    }

    public class override var runtimeType: String {
        #if os(tvOS)
            return "UIView"
        #else
        return "UISwitch"
        #endif
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        #if os(tvOS)
            return UIView()
        #else
            return UISwitch()
        #endif
    }
    #endif
}

public class SwitchProperties: ViewProperties {
    public let isOn: AssignablePropertyDescription<Bool>
    public let onTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let thumbTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let onImage: AssignablePropertyDescription<Image>
    public let offImage: AssignablePropertyDescription<Image>
    
    public required init(configuration: Configuration) {
        isOn = configuration.property(name: "isOn")
        onTintColor = configuration.property(name: "onTintColor")
        thumbTintColor = configuration.property(name: "thumbTintColor")
        onImage = configuration.property(name: "onImage")
        offImage = configuration.property(name: "offImage")
        
        super.init(configuration: configuration)
    }
}
