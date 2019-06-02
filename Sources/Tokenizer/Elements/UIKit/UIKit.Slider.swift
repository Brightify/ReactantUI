//
//  Slider.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class Slider: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.slider.allProperties
    }

    public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
        switch platform {
        case .iOS:
            return RuntimeType(name: "UISlider", module: "UIKit")
        case .tvOS:
            throw TokenizationError.unsupportedElementError(element: Slider.self)
        }
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: Slider.self)
        #else
            return UISlider()
        #endif
    }
    #endif
}

public class SliderProperties: ControlProperties {
    public let value: AssignablePropertyDescription<Double>
    public let minimumValue: AssignablePropertyDescription<Double>
    public let maximumValue: AssignablePropertyDescription<Double>
    public let isContinuous: AssignablePropertyDescription<Bool>
    public let minimumValueImage: AssignablePropertyDescription<Image?>
    public let maximumValueImage: AssignablePropertyDescription<Image?>
    public let minimumTrackTintColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let currentMinimumTrackImage: AssignablePropertyDescription<Image?>
    public let maximumTrackTintColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let currentMaximumTrackImage: AssignablePropertyDescription<Image?>
    public let thumbTintColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let currentThumbImage: AssignablePropertyDescription<Image?>
    
    public required init(configuration: Configuration) {
        value = configuration.property(name: "value")
        minimumValue = configuration.property(name: "minimumValue")
        maximumValue = configuration.property(name: "maximumValue", defaultValue: 1)
        isContinuous = configuration.property(name: "isContinuous", defaultValue: true)
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
