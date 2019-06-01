//
//  ConstraintType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

public enum ConstraintType {
    case constant(Double)
    case targeted(target: ConstraintTarget, targetAnchor: LayoutAnchor, multiplier: Double, constant: Double)
}

extension ConstraintType: Equatable {
    public static func ==(lhs: ConstraintType, rhs: ConstraintType) -> Bool {
        switch(lhs, rhs) {
        case (.constant(let lhsConstant), .constant(let rhsConstant)):
            return lhsConstant == rhsConstant
        case (.targeted(let lhsTarget, let lhsAnchor, let lhsMultiplier, let lhsConstant), .targeted(let rhsTarget, let rhsAnchor, let rhsMultiplier, let rhsConstant)):
            return lhsTarget == rhsTarget && lhsAnchor == rhsAnchor && lhsMultiplier == rhsMultiplier && lhsConstant == rhsConstant
        default:
            return false
        }
    }
}
