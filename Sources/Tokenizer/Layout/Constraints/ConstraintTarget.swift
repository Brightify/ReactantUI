//
//  ConstraintTarget.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

public enum ConstraintTarget {
    case field(String)
    case layoutId(String)
    case parent
    case this
    case safeAreaLayoutGuide
    case readableContentGuide
}

extension ConstraintTarget: Equatable {
    public static func ==(lhs: ConstraintTarget, rhs: ConstraintTarget) -> Bool {
        switch (lhs, rhs) {
        case (.field(let lhsField), .field(let rhsField)):
            return lhsField == rhsField
        case (.layoutId(let lhsId), .layoutId(let rhsId)):
            return lhsId == rhsId
        case (.parent, .parent), (.this, .this), (.safeAreaLayoutGuide, .safeAreaLayoutGuide), (.readableContentGuide, .readableContentGuide):
            return true
        default:
            return false
        }
    }
}
