//
//  XSDComplexType.swift
//  ReactantUIPackageDescription
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

struct XSDComplexChoiceType {
    let name: String
    var elements: Set<XSDElement>
}

extension XSDComplexChoiceType: Hashable {
    var hashValue: Int {
        return name.hashValue
    }

    static func ==(lhs: XSDComplexChoiceType, rhs: XSDComplexChoiceType) -> Bool {
        return lhs.name == rhs.name
    }
}

extension XSDComplexChoiceType: MagicElementSerializable {
    func serialize() -> MagicElement {
        let elements = self.elements.map { $0.serialize() }
        let choice = MagicElement(name: "xs:choice", attributes: [MagicAttribute(name: "maxOccurs", value: "unbounded"),
                                                                  MagicAttribute(name: "minOccurs", value: "0")], children: elements)
        return MagicElement(name: "xs:complexType", attributes: [MagicAttribute(name: "name", value: name)], children: [choice])
    }
}
