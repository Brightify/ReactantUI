//
//  Stepper.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class Stepper: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.stepper.allProperties
    }

    public class override var runtimeType: String {
        #if os(tvOS)
            return "UIView"
        #else
            return "UIStepper"
        #endif
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        #if os(tvOS)
            return UIView()
        #else
            return UIStepper()
        #endif
    }
    #endif
}

public class StepperProperties: ViewProperties {
    public let value: AssignablePropertyDescription<Double>
    public let minimumValue: AssignablePropertyDescription<Double>
    public let maximumValue: AssignablePropertyDescription<Double>
    public let stepValue: AssignablePropertyDescription<Double>
    public let isContinuous: AssignablePropertyDescription<Bool>
    public let autorepeat: AssignablePropertyDescription<Bool>
    public let wraps: AssignablePropertyDescription<Bool>
    
    public required init(configuration: Configuration) {
        value = configuration.property(name: "value")
        minimumValue = configuration.property(name: "minimumValue")
        maximumValue = configuration.property(name: "maximumValue")
        stepValue = configuration.property(name: "stepValue")
        isContinuous = configuration.property(name: "isContinuous", key: "continuous")
        autorepeat = configuration.property(name: "autorepeat")
        wraps = configuration.property(name: "wraps")
        
        super.init(configuration: configuration)
    }
}
