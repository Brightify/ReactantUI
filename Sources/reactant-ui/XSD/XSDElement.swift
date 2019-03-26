//
//  XSDElement.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

struct XSDElement {
    let name: String
    let isContainer: Bool
    var attributeGroups = Set<String>()
}

extension XSDElement: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func ==(lhs: XSDElement, rhs: XSDElement) -> Bool {
        return lhs.name == rhs.name
    }
}

extension XSDElement: XMLElementSerializable {
    func serialize(context: DataContext) -> XMLSerializableElement {
        var attributeBuilder = XMLAttributeBuilder()
        attributeBuilder.attribute(name: "name", value: name)
        attributeBuilder.attribute(name: "maxOccurs", value: "unbounded")
        attributeBuilder.attribute(name: "minOccurs", value: "0")
        let attributeGroupRefs = attributeGroups.map {
            XMLSerializableElement(name: "xs:attributeGroup", attributes: [XMLSerializableAttribute(name: "ref", value: $0)], children: [])
        }
        let complexTypeChildren: [XMLSerializableElement]

        if isContainer {
            let groupRef = XMLSerializableElement(name: "xs:group", attributes: [XMLSerializableAttribute(name: "ref", value: "viewGroup")], children: [])
            let choice = XMLSerializableElement(name: "xs:choice",
                                      attributes: [XMLSerializableAttribute(name: "maxOccurs", value: "unbounded"),
                                                   XMLSerializableAttribute(name: "minOccurs", value: "0")],
                                      children: [groupRef])
            complexTypeChildren = [choice] + attributeGroupRefs
        } else {
            complexTypeChildren = attributeGroupRefs
        }

        let complexType = XMLSerializableElement(name: "xs:complexType", attributes: [], children: complexTypeChildren)


        return XMLSerializableElement(name: "xs:element", attributes: attributeBuilder.attributes, children: [complexType])
    }
}
