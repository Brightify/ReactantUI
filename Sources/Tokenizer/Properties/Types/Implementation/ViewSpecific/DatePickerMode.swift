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

    static var allValues: [DatePickerMode] = [.date, .time, .dateAndTime, .countDownTimer]

    public static var xsdType: XSDType {
        let values = Set(DatePickerMode.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: DatePickerMode.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
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
