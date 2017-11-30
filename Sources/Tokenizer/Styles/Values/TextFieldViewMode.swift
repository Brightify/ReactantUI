//
//  TextFieldViewMode.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 28/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum TextFieldViewMode: String, EnumPropertyType {
    public static let enumName = "UITextFieldViewMode"

    case never
    case whileEditing
    case unlessEditing
    case always
}


#if ReactantRuntime
    import UIKit

    extension TextFieldViewMode {

        public var runtimeValue: Any? {
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
