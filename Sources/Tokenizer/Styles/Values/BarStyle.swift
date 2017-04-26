//
//  BarStyle.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public protocol Appliable {

    var value: Any? { get }
}

public enum BarStyle: String {
    case `default`
    case black
    case blackTranslucent
}

#if ReactantRuntime
import UIKit
    
extension BarStyle: Appliable {

    public var value: Any? {
        switch self {
        case .`default`:
            return UIBarStyle.default.rawValue
        case .black:
            return UIBarStyle.black.rawValue
        case .blackTranslucent:
            return UIBarStyle.blackTranslucent.rawValue
        }
    }
    }
#endif
