//
//  StyleGroup.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public struct StyleGroup: XMLElementDeserializable {
    public var swiftName: String {
        return name.capitalizingFirstLetter() + "Styles"
    }
    public var name: String
    public var styles: [Style]

    public static func deserialize(_ node: XMLElement) throws -> StyleGroup {
        let groupName = try node.value(ofAttribute: "name") as String
        return try StyleGroup(
            name: groupName,
            styles: node.xmlChildren.compactMap { try Style(node: $0, groupName: groupName) })
    }
}
