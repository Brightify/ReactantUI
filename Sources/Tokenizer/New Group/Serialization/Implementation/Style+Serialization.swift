//
//  Style+Serializable.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

extension Style: XMLElementSerializable {
    public func serialize() -> XMLSerializableElement {
        var builder = XMLAttributeBuilder()
        builder.attribute(name: "name", value: name)
        let extendedStyles = extend.joined(separator: " ")
        if !extendedStyles.isEmpty {
            builder.attribute(name: "extend", value: extendedStyles)
        }
        #if SanAndreas
            properties.map { $0.dematerialize() }.forEach { builder.add(attribute: $0) }
        #endif

        return XMLSerializableElement(name: "\(type)Style", attributes: builder.attributes, children: [])
    }
}
