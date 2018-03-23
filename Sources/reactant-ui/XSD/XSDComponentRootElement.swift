//
//  XSDComponentRootElement.swift
//  ReactantUIPackageDescription
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

struct XSDComponentRootElement: MagicElementSerializable {
    func serialize() -> MagicElement {
        let groupRef = MagicElement(name: "xs:group", attributes: [MagicAttribute(name: "ref", value: "viewGroup")], children: [])
        let styles = MagicElement(name: "xs:element", attributes: [MagicAttribute(name: "name", value: "styles"),
                                                                   MagicAttribute(name: "maxOccurs", value: "1"),
                                                                   MagicAttribute(name: "minOccurs", value: "0"),
                                                                   MagicAttribute(name: "type", value: "stylesType")], children: [])
        let choice = MagicElement(name: "xs:choice",
                                  attributes: [MagicAttribute(name: "maxOccurs", value: "unbounded"),
                                               MagicAttribute(name: "minOccurs", value: "0")],
                                  children: [groupRef, styles])
        let attributes = [
            MagicElement(name: "xs:attribute", attributes: [MagicAttribute(name: "name", value: "type"),
                                                            MagicAttribute(name: "type", value: "xs:string")], children: []),
            MagicElement(name: "xs:attribute", attributes: [MagicAttribute(name: "name", value: "rootView"),
                                                            MagicAttribute(name: "type", value: "xs:boolean"),
                                                            MagicAttribute(name: "default", value: "false")], children: []),
            MagicElement(name: "xs:attribute", attributes: [MagicAttribute(name: "name", value: "extend"),
                                                            MagicAttribute(name: "type", value: "rectEdge")], children: []),
            MagicElement(name: "xs:attribute", attributes: [MagicAttribute(name: "name", value: "anonymous"),
                                                            MagicAttribute(name: "type", value: "xs:boolean"),
                                                            MagicAttribute(name: "default", value: "false")], children: []),
            MagicElement(name: "xs:attributeGroup", attributes: [MagicAttribute(name: "ref", value: "ViewAttributes")], children: []),
        ]
        let complexType = MagicElement(name: "xs:complexType", attributes: [], children: [choice] + attributes)
        return MagicElement(name: "xs:element", attributes: [MagicAttribute(name: "name", value: "Component")], children: [complexType])
    }
}
