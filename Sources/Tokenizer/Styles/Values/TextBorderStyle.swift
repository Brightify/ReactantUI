//
//  TextBorderStyle.swift
//  Pods
//
//  Created by Matouš Hýbl on 28/04/2017.
//
//

import Foundation

public enum TextBorderStyle: String {
    case none
    case line
    case bezel
    case roundedRect
}

#if ReactantRuntime
    import UIKit

    extension TextBorderStyle: Applicable {

        public var value: Any? {
            switch self {
            case .none:
                return UITextBorderStyle.none.rawValue
            case .line:
                return UITextBorderStyle.line.rawValue
            case .bezel:
                return UITextBorderStyle.bezel.rawValue
            case .roundedRect:
                return UITextBorderStyle.roundedRect.rawValue
            }
        }
    }
    
#endif
