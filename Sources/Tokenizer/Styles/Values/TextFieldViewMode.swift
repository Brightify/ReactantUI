//
//  TextFieldViewMode.swift
//  Pods
//
//  Created by Matouš Hýbl on 28/04/2017.
//
//

import Foundation

public enum TextFieldViewMode: String {
    case never
    case whileEditing
    case unlessEditing
    case always
}

#if ReactantRuntime

    extension TextFieldViewMode: Applicable {

        public var value: Any? {
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
