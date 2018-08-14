//
//  TextFieldViewMode.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 28/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum TextFieldViewMode: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UITextFieldViewMode"

    case never
    case whileEditing
    case unlessEditing
    case always

    public static let allValues: [TextFieldViewMode] = [.never, .whileEditing, .unlessEditing, .always]
}


#if canImport(UIKit)
    import UIKit

    extension TextFieldViewMode {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            switch self {
            case .never:
                return UITextFieldViewMode.never.rawValue
            case .whileEditing:
                return UITextFieldViewMode.whileEditing.rawValue
            case .unlessEditing:
                return UITextFieldViewMode.unlessEditing.rawValue
            case .always:
                return UITextFieldViewMode.always.rawValue
            }
        }
    }
    
#endif
