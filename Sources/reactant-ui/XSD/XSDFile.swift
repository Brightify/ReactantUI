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
    func serialize(context: DataContext) -> XMLSerializableElement {
        let simpleTypes = self.simpleTypes.map { $0.serialize(context: context) }
        let complexTypes = self.complexTypes.map { $0.serialize(context: context) }
        let attributeGroups = self.attributeGroups.map { $0.serialize(context: context) }
        let groups = self.groups.map { $0.serialize(context: context) }
        let elements = self.elements.map { $0.serialize(context: context) }
        return XMLSerializableElement(name: "xs:schema",
                                      attributes: [],
                                      children: simpleTypes + complexTypes + attributeGroups + groups + elements)
    }
}
