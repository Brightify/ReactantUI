//
//  DatePickerMode.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum DatePickerMode: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIDatePickerMode"

    case date
    case time
    case dateAndTime
    case countDownTimer

    public static let allValues: [DatePickerMode] = [.date, .time, .dateAndTime, .countDownTimer]
}

#if canImport(UIKit)
import UIKit

extension DatePickerMode {

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        #if os(tvOS)
            return nil
        #else
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
        #endif
    }
}
#endif
