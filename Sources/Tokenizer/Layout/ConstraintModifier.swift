//
//  ConstraintModifier.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ConstraintModifier {
    case multiplied(by: Float)
    case divided(by: Float)
    case offset(by: Float)
    case inset(by: Float)
}
