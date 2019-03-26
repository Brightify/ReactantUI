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
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func ==(lhs: XSDAttributeGroup, rhs: XSDAttributeGroup) -> Bool {
        return lhs.name == rhs.name
    }
}

extension XSDAttributeGroup: XMLElementSerializable {
    func serialize(context: DataContext) -> XMLSerializableElement {
        let attributes = self.attributes.map { $0.serialize(context: context) }
        return XMLSerializableElement(name: "xs:attributeGroup",
                                      attributes: [XMLSerializableAttribute(name: "name", value: name)],
                                      children: attributes)
    }
}
