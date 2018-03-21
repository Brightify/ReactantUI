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
    var hashValue: Int {
        return name.hashValue
    }

    static func ==(lhs: XSDElement, rhs: XSDElement) -> Bool {
        return lhs.name == rhs.name
    }
}

//<xs:complexType>
//<xs:complexContent>
//<xs:extension base="viewType">
//<xs:choice maxOccurs="unbounded" minOccurs="0">
//<xs:group ref="ViewGroup"/>
//</xs:choice>
//</xs:extension>
//</xs:complexContent>
//</xs:complexType>
extension XSDElement: MagicElementSerializable {
    func serialize() -> MagicElement {
        var attributeBuilder = MagicAttributeBuilder()
        attributeBuilder.attribute(name: "name", value: name)
        attributeBuilder.attribute(name: "maxOccurs", value: "unbounded")
        attributeBuilder.attribute(name: "minOccurs", value: "0")
        let attributeGroupRefs = attributeGroups.map {
            MagicElement(name: "xs:attributeGroup", attributes: [MagicAttribute(name: "ref", value: $0)], children: [])
        }
        let complexTypeChildren: [MagicElement]

        if isContainer {
            let groupRef = MagicElement(name: "xs:group", attributes: [MagicAttribute(name: "ref", value: "viewGroup")], children: [])
            let choice = MagicElement(name: "xs:choice",
                                      attributes: [MagicAttribute(name: "maxOccurs", value: "unbounded"),
                                                   MagicAttribute(name: "minOccurs", value: "0")],
                                      children: [groupRef])
            complexTypeChildren = [choice] + attributeGroupRefs 
        } else {
            complexTypeChildren = attributeGroupRefs
        }

        //        let complexContent = MagicElement(name: "xs:complexContent", attributes: [], children: attributeGroupRefs)
        let complexType = MagicElement(name: "xs:complexType", attributes: [], children: complexTypeChildren)//[complexContent])


        return MagicElement(name: "xs:element", attributes: attributeBuilder.attributes, children: [complexType])
    }
}
