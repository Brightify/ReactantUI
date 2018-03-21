//
//  XSDComplexType.swift
//  ReactantUIPackageDescription
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

struct XSDComplexType {
    let name: String
}

extension XSDComplexType: Hashable, Equatable {
    var hashValue: Int {
        return name.hashValue
    }

    static func ==(lhs: XSDComplexType, rhs: XSDComplexType) -> Bool {
        return lhs.name == rhs.name
    }
}
