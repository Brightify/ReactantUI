//
//  Stepper.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class Stepper: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.stepper.allProperties
    }

    public class override func runtimeType() throws -> String {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: Stepper.self)
        #else
            return "UIStepper"
        #endif
    }

    #if canImport(UIKit)
    public override func initialize() throws -> UIView {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: Stepper.self)
        #else
            return UIStepper()
        #endif
    }
    #endif
}

public class StepperProperties: ControlProperties {
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
