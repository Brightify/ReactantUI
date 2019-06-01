//
//  ConstraintModifier.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ConstraintModifier {
    case multiplied(by: Double)
    case divided(by: Double)
    case offset(by: Double)
    case inset(by: Double)
}
