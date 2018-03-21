//
//  XSDAttributeGroup.swift
//  ReactantUIPackageDescription
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

struct XSDAttributeGroup {
    let name: String

    var attributes = Set<XSDAttribute>()

}

extension XSDAttributeGroup: Hashable, Equatable {
    var hashValue: Int {
        return name.hashValue
    }

    static func ==(lhs: XSDAttributeGroup, rhs: XSDAttributeGroup) -> Bool {
        return lhs.name == rhs.name
    }
}

extension XSDAttributeGroup: MagicElementSerializable {
    func serialize() -> MagicElement {
        let attributes = self.attributes.map { $0.serialize() }
        return MagicElement(name: "xs:attributeGroup", attributes: [MagicAttribute(name: "name", value: name)], children: attributes)
    }
}
