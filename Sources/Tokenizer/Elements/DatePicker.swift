//
//  DatePicker.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class DatePicker: View {
    override class var availableProperties: [PropertyDescription] {
        return Properties.datePicker.allProperties
    }

    public class override var runtimeType: String {
        #if os(tvOS)
            return "UIView"
        #else
        return "UIDatePicker"
        #endif
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        #if os(tvOS)
            return UIView()
        #else
            return UIDatePicker()
        #endif
    }
    #endif
}

public class DatePickerProperties: ViewProperties {
    public let minuteInterval: AssignablePropertyDescription<Int>
    public let mode: AssignablePropertyDescription<DatePickerMode>
    
    public required init(configuration: PropertyContainer.Configuration) {
        minuteInterval = configuration.property(name: "minuteInterval")
        mode = configuration.property(name: "mode", swiftName: "datePickerMode", key: "datePickerMode")
        super.init(configuration: configuration)
    }
}
