//
//  DatePicker.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class DatePicker: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.datePicker.allProperties
    }

    public class override func runtimeType() throws -> String {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: DatePicker.self)
        #else
        return "UIDatePicker"
        #endif
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: DatePicker.self)
        #else
            return UIDatePicker()
        #endif
    }
    #endif
}

public class DatePickerProperties: ControlProperties {
    public let minuteInterval: AssignablePropertyDescription<Int>
    public let mode: AssignablePropertyDescription<DatePickerMode>
    
    public required init(configuration: PropertyContainer.Configuration) {
        minuteInterval = configuration.property(name: "minuteInterval")
        mode = configuration.property(name: "mode", swiftName: "datePickerMode", key: "datePickerMode")
        super.init(configuration: configuration)
    }
}
