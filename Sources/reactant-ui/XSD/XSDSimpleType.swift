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

extension XSDSimpleType: MagicElementSerializable {
    func serialize() -> MagicElement {
        var attributeBuilder = MagicAttributeBuilder()

        attributeBuilder.attribute(name: "name", value: name)

        switch type {
        case .builtin:
            fatalError("builtin type cannot be serialized")
        case .enumeration(let enumeration):
            let enumerations = enumeration.values.map { value in
                return MagicElement(name: "xs:enumeration", attributes: [ MagicAttribute(name: "value", value: value) ], children: [])
            }

            let restriction = MagicElement(name: "xs:restriction", attributes: [MagicAttribute(name: "base", value: "xs:string")], children: enumerations)
            return MagicElement(name: "xs:simpleType", attributes: attributeBuilder.attributes, children: [restriction])
        case .pattern(let pattern):
            let pattern = MagicElement(name: "xs:pattern",
                                       attributes: [ MagicAttribute(name: "value", value: pattern.value)],
                                       children: [])

            let restriction = MagicElement(name: "xs:restriction",
                                           attributes: [MagicAttribute(name: "base", value: "xs:token")],
                                           children: [pattern])
            return MagicElement(name: "xs:simpleType", attributes: attributeBuilder.attributes, children: [restriction])
        case .union(let union):
            let union = MagicElement(name: "xs:union",
                                     attributes: [MagicAttribute(name: "memberTypes", value: union.memberTypes.map { $0.name }.joined(separator: " "))],
                                     children: [])
            return MagicElement(name: "xs:simpleType", attributes: attributeBuilder.attributes, children: [union])
        }

        return MagicElement(name: "xs:simpleType", attributes: attributeBuilder.attributes, children: [])
    }
}

extension XSDSimpleType: Hashable, Equatable {
    var hashValue: Int {
        return name.hashValue
    }

    static func ==(lhs: XSDSimpleType, rhs: XSDSimpleType) -> Bool {
        return lhs.name == rhs.name
    }
}
