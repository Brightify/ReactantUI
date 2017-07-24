//
//  DatePickerMode.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum DatePickerMode: String, EnumPropertyType {
    public static let enumName = "UIDatePickerMode"

    case date
    case time
    case dateAndTime
    case countDownTimer
}

#if ReactantRuntime
import UIKit

extension DatePickerMode {

    public var runtimeValue: Any? {
        switch self {
        case .time:
            return UIDatePickerMode.time.rawValue
        case .date:
            return UIDatePickerMode.date.rawValue
        case .dateAndTime:
            return UIDatePickerMode.dateAndTime.rawValue
        case .countDownTimer:
            return UIDatePickerMode.countDownTimer.rawValue
        }
    }
}
#endif
