//
//  XSDComponentRootElement.swift
//  ReactantUIPackageDescription
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

struct XSDComponentRootElement: XMLElementSerializable {
    func serialize(context: DataContext) -> XMLSerializableElement {
        let groupRef = XMLSerializableElement(name: "xs:group", attributes: [XMLSerializableAttribute(name: "ref", value: "viewGroup")], children: [])
        let styles = XMLSerializableElement(name: "xs:element", attributes: [XMLSerializableAttribute(name: "name", value: "styles"),
                                                                   XMLSerializableAttribute(name: "maxOccurs", value: "1"),
                                                                   XMLSerializableAttribute(name: "minOccurs", value: "0"),
                                                                   XMLSerializableAttribute(name: "type", value: "stylesType")], children: [])
        let choice = XMLSerializableElement(name: "xs:choice",
                                  attributes: [XMLSerializableAttribute(name: "maxOccurs", value: "unbounded"),
                                               XMLSerializableAttribute(name: "minOccurs", value: "0")],
                                  children: [groupRef, styles])
        let attributes = [
            XMLSerializableElement(name: "xs:attribute", attributes: [XMLSerializableAttribute(name: "name", value: "type"),
                                                            XMLSerializableAttribute(name: "type", value: "xs:string")], children: []),
            XMLSerializableElement(name: "xs:attribute", attributes: [XMLSerializableAttribute(name: "name", value: "rootView"),
                                                            XMLSerializableAttribute(name: "type", value: "xs:boolean"),
                                                            XMLSerializableAttribute(name: "default", value: "false")], children: []),
            XMLSerializableElement(name: "xs:attribute", attributes: [XMLSerializableAttribute(name: "name", value: "extend"),
                                                            XMLSerializableAttribute(name: "type", value: "rectEdge")], children: []),
            XMLSerializableElement(name: "xs:attribute", attributes: [XMLSerializableAttribute(name: "name", value: "anonymous"),
                                                            XMLSerializableAttribute(name: "type", value: "xs:boolean"),
                                                            XMLSerializableAttribute(name: "default", value: "false")], children: []),
            XMLSerializableElement(name: "xs:attributeGroup", attributes: [XMLSerializableAttribute(name: "ref", value: "ViewAttributes")], children: []),
        ]
        let complexType = XMLSerializableElement(name: "xs:complexType", attributes: [], children: [choice] + attributes)

        return XMLSerializableElement(name: "xs:element",
                                      attributes: [XMLSerializableAttribute(name: "name", value: "Component")],
                                      children: [complexType])
    }
}
