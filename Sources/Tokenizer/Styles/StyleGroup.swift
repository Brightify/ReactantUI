//
//  StyleGroup.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

/**
 * Structure containing multiple `Style` structures.
 * It represents the **<styles>** tag either inside a component definition or in global styles.
 */
public struct StyleGroup {
    public var swiftName: String {
        return name.capitalizingFirstLetter() + "Styles"
    }
    public var name: String
    public var accessModifier: AccessModifier
    public var styles: [Style]

    public init(name: String, accessModifier: AccessModifier, styles: [Style]) {
        self.name = name
        self.accessModifier = accessModifier
        self.styles = styles
    }

    public init(context: StyleGroupDeserializationContext) throws {
        let node = context.element
        let name = try node.value(ofAttribute: "name") as String
        self.name = name
        if let modifier = node.value(ofAttribute: "accessModifier") as String? {
            accessModifier = AccessModifier(rawValue: modifier) ?? .internal
        } else {
            accessModifier = .internal
        }

        styles = try node.xmlChildren.compactMap {
            try context.deserialize(element: $0, groupName: name)
        }
    }
}
