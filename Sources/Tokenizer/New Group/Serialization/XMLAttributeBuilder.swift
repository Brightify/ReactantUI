//
//  XMLAttributeBuilder.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

public struct XMLAttributeBuilder {
    public let namespace: String
    public private(set) var attributes: [XMLSerializableAttribute] = []

    public init(namespace: String = "") {
        self.namespace = namespace
    }

    public mutating func add(attribute: XMLSerializableAttribute) {
        var newAttribute = attribute
        if !namespace.isEmpty {
            newAttribute.name = "\(namespace):\(newAttribute.name)"
        }

        if let index = attributes.index(where: { $0.name == attribute.name }) {
            swap(&attributes[index], &newAttribute)
        } else {
            attributes.append(newAttribute)
        }
    }

    public mutating func attribute(name: String, value: String) {
        add(attribute: XMLSerializableAttribute(name: name, value: value))
    }
}
