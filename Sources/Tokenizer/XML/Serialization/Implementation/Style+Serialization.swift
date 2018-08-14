//
//  Style+Serializable.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

extension Style: XMLElementSerializable {
    public func serialize(context: DataContext) -> XMLSerializableElement {
        var builder = XMLAttributeBuilder()
        builder.attribute(name: "name", value: name.name)
        let extendedStyles = extend.map { $0.serialize() }.joined(separator: " ")
        if !extendedStyles.isEmpty {
            builder.attribute(name: "extend", value: extendedStyles)
        }
        #if SanAndreas
            properties
                .map {
                    $0.dematerialize(context: PropertyContext(parentContext: context, property: $0))
                }
                .forEach {
                    builder.add(attribute: $0)
                }
        #endif

        return XMLSerializableElement(name: "\(type.styleType)Style", attributes: builder.attributes, children: [])
    }
}
