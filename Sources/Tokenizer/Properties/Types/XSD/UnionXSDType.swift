//
//  UnionType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

public struct UnionXSDType {
    public let name: String
    public let memberTypes: [XSDType]

    public init(name: String, memberTypes: [XSDType]) {
        self.name = name
        self.memberTypes = memberTypes
    }
}
