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
public struct StyleGroup: XMLElementDeserializable {
    public var swiftName: String {
        return name.capitalizingFirstLetter() + "Styles"
    }
    public var name: String
    public var styles: [Style]

    /**
     * Tries to obtain a `StyleGroup` from an XML element.
     * - parameter node: the XML element to parse
     * - returns: if not thrown, parsed `StyleGroup` structure
     */
    public static func deserialize(_ node: XMLElement) throws -> StyleGroup {
        let groupName = try node.value(ofAttribute: "name") as String
        return try StyleGroup(
            name: groupName,
            styles: node.xmlChildren.compactMap { try Style(node: $0, groupName: groupName) })
    }
}
