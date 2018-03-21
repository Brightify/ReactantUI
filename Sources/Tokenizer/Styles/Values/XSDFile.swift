//
//  XSDFile.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

struct XSDFile {
    var simpleTypes = Set<XSDSimpleType>()
    var complexTypes = Set<XSDComplexType>()
    var attributeGroups = Set<XSDAttributeGroup>()
    var groups = Set<XSDGroup>()
    var elements = Set<XSDElement>()

    var serializedElements: [MagicElement] {
        return elements.map { $0.serialize() } +
            groups.map { $0.serialize() } +
            attributeGroups.map { $0.serialize() } +
            simpleTypes.map { $0.serialize() }
    }
}

extension XSDFile: MagicElementSerializable {
    func serialize() -> MagicElement {
        return MagicElement(name: "xs:schema", attributes: [], children: serializedElements)
    }
}
