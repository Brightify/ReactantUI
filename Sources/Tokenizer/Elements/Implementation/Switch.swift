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
    public override class var availableProperties: [PropertyDescription] {
        return Properties.switch.allProperties
    }

    public class override func runtimeType() throws -> String {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: Switch.self)
        #else
        return "UISwitch"
        #endif
    }

    #if ReactantRuntime
    public override func initialize() throws -> UIView {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: Switch.self)
        #else
            return UISwitch()
        #endif
    }
    #endif
}

public class SwitchProperties: ControlProperties {
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
