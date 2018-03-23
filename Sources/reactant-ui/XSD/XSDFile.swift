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
    var complexTypes = Set<XSDComplexChoiceType>()
    var attributeGroups = Set<XSDAttributeGroup>()
    var groups = Set<XSDGroup>()
    var elements = Set<XSDElement>()
}

extension XSDFile: XMLElementSerializable {
    func serialize() -> XMLSerializableElement {
        let simpleTypes = self.simpleTypes.map { $0.serialize() }
        let complexTypes = self.complexTypes.map { $0.serialize() }
        let attributeGroups = self.attributeGroups.map { $0.serialize() }
        let groups = self.groups.map { $0.serialize() }
        let elements = self.elements.map { $0.serialize() }
        return XMLSerializableElement(name: "xs:schema",
                                      attributes: [],
                                      children: simpleTypes + complexTypes + attributeGroups + groups + elements)
    }
}
