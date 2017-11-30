//
//  Slider.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Slider: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.slider.allProperties
    }

    public class override var runtimeType: String {
        return "UISlider"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UISlider()
    }
    #endif
}

public class SliderProperties: ViewProperties {
    public let value: AssignablePropertyDescription<Float>
    public let minimumValue: AssignablePropertyDescription<Float>
    public let maximumValue: AssignablePropertyDescription<Float>
    public let isContinuous: AssignablePropertyDescription<Bool>
    public let minimumValueImage: AssignablePropertyDescription<Image>
    public let maximumValueImage: AssignablePropertyDescription<Image>
    public let minimumTrackTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let currentMinimumTrackImage: AssignablePropertyDescription<Image>
    public let maximumTrackTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let currentMaximumTrackImage: AssignablePropertyDescription<Image>
    public let thumbTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let currentThumbImage: AssignablePropertyDescription<Image>
    
    public required init(configuration: Configuration) {
        value = configuration.property(name: "value")
        minimumValue = configuration.property(name: "minimumValue")
        maximumValue = configuration.property(name: "maximumValue")
        isContinuous = configuration.property(name: "isContinuous")
        minimumValueImage = configuration.property(name: "minimumValueImage")
        maximumValueImage = configuration.property(name: "maximumValueImage")
        minimumTrackTintColor = configuration.property(name: "minimumTrackTintColor")
        currentMinimumTrackImage = configuration.property(name: "currentMinimumTrackImage")
        maximumTrackTintColor = configuration.property(name: "maximumTrackTintColor")
        currentMaximumTrackImage = configuration.property(name: "currentMaximumTrackImage")
        thumbTintColor = configuration.property(name: "thumbTintColor")
        currentThumbImage = configuration.property(name: "currentThumbImage")
        
        super.init(configuration: configuration)
    }
}
