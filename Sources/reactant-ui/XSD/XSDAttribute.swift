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
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    public static func ==(lhs: XSDAttribute, rhs: XSDAttribute) -> Bool {
        return lhs.name == rhs.name && lhs.typeName == rhs.typeName
    }
}

extension XSDAttribute: XMLElementSerializable {
    func serialize(context: DataContext) -> XMLSerializableElement {
        return XMLSerializableElement(name: "xs:attribute",
                            attributes: [XMLSerializableAttribute(name: "name", value: name),
                                         XMLSerializableAttribute(name: "type", value: typeName)],
                            children: [])
    }
}
