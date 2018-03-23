//
//  XSDType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

public enum XSDType {
    case builtin(BuiltinXSDType)
    case enumeration(EnumerationXSDType)
    case union(UnionXSDType)
    case pattern(PatternXSDType)

    public var name: String {
        switch self {
        case .builtin(let builtin):
            return builtin.xsdName
        case .enumeration(let enumeration):
            return enumeration.name
        case .union(let union):
            return union.name
        case .pattern(let pattern):
            return pattern.name
        }
    }
}
