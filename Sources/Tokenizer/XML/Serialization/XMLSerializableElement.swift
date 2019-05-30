//
//  XMLSerializableElement.swift
//  Hyperdrive-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

public struct XMLSerializableElement {
    public var name: String
    public var attributes: [XMLSerializableAttribute]
    public var children: [XMLSerializableElement]

    public init(name: String, attributes: [XMLSerializableAttribute] = [], children: [XMLSerializableElement] = []) {
        self.name = name
        self.attributes = attributes
        self.children = children
    }
}
