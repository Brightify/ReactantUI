//
//  EnumerationType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

public struct EnumerationXSDType {
    public let name: String
    public let base: BuiltinXSDType
    public let values: Set<String>

    public init(name: String, base: BuiltinXSDType, values: Set<String>) {
        self.name = name
        self.base = base
        self.values = values
    }
}
