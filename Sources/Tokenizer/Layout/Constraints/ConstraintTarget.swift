//
//  ConstraintTarget.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

public enum ConstraintTarget {
    case identifier(String)
    case parent
    case this
    case safeAreaLayoutGuide
    case readableContentGuide
}

extension ConstraintTarget: Equatable {
    public static func ==(lhs: ConstraintTarget, rhs: ConstraintTarget) -> Bool {
        switch (lhs, rhs) {
        case (.identifier(let lhsField), .identifier(let rhsField)):
            return lhsField == rhsField
        case (.parent, .parent), (.this, .this), (.safeAreaLayoutGuide, .safeAreaLayoutGuide), (.readableContentGuide, .readableContentGuide):
            return true
        default:
            return false
        }
    }
}
