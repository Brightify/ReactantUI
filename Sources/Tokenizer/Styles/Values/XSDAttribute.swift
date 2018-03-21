//
//  XSDAttribute.swift
//  ReactantUIPackageDescription
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

struct XSDAttribute {
    let name: String
    let typeName: String
}

extension XSDAttribute: Equatable, Hashable {
    var hashValue: Int {
        return name.hashValue
    }

    public static func ==(lhs: XSDAttribute, rhs: XSDAttribute) -> Bool {
        return lhs.name == rhs.name && lhs.typeName == rhs.typeName
    }
}

extension XSDAttribute: MagicElementSerializable {
    func serialize() -> MagicElement {
        return MagicElement(name: "xs:attribute",
                            attributes: [MagicAttribute(name: "name", value: name), MagicAttribute(name: "type", value: typeName)],
                            children: [])
    }
}
