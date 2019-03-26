//
//  XSDSimpleType.swift
//  ReactantUIPackageDescription
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Tokenizer
import Foundation

struct XSDSimpleType {
    let name: String
    let type: XSDType
}

extension XSDSimpleType: XMLElementSerializable {
    func serialize(context: DataContext) -> XMLSerializableElement {
        var attributeBuilder = XMLAttributeBuilder()

        attributeBuilder.attribute(name: "name", value: name)

        switch type {
        case .builtin:
            fatalError("builtin type cannot be serialized")
        case .enumeration(let enumeration):
            let enumerations = enumeration.values.map { value in
                return XMLSerializableElement(name: "xs:enumeration",
                                              attributes: [XMLSerializableAttribute(name: "value", value: value)],
                                              children: [])
            }

            let restriction = XMLSerializableElement(name: "xs:restriction",
                                                     attributes: [XMLSerializableAttribute(name: "base", value: "xs:string")],
                                                     children: enumerations)

            return XMLSerializableElement(name: "xs:simpleType", attributes: attributeBuilder.attributes, children: [restriction])
        case .pattern(let pattern):
            let pattern = XMLSerializableElement(name: "xs:pattern",
                                       attributes: [ XMLSerializableAttribute(name: "value", value: pattern.value)],
                                       children: [])

            let restriction = XMLSerializableElement(name: "xs:restriction",
                                           attributes: [XMLSerializableAttribute(name: "base", value: "xs:token")],
                                           children: [pattern])

            return XMLSerializableElement(name: "xs:simpleType", attributes: attributeBuilder.attributes, children: [restriction])
        case .union(let union):
            let union = XMLSerializableElement(name: "xs:union",
                                     attributes: [XMLSerializableAttribute(name: "memberTypes",
                                                                           value: union.memberTypes.map { $0.name }.joined(separator: " "))],
                                     children: [])
            
            return XMLSerializableElement(name: "xs:simpleType", attributes: attributeBuilder.attributes, children: [union])
        }
    }
}

extension XSDSimpleType: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func ==(lhs: XSDSimpleType, rhs: XSDSimpleType) -> Bool {
        return lhs.name == rhs.name
    }
}
