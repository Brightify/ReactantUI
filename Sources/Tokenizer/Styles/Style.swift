//
//  Style.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct Style: XMLElementDeserializable {
    public var type: String
    // this is name with group
    public var name: String
    // this is name of the style without group name
    public var styleName: String
    public var extend: [String]
    public var properties: [Property]
    public var groupName: String?

    public var parentModuleImport: String

    init(node: XMLElement, groupName: String? = nil) throws {
        let properties: [Property]
        let type: String

        guard let (elementName, element) = Element.elementMapping.first(where: { node.name == "\($0.key)Style" }) else {
            throw TokenizationError(message: "Unknown style \(node.name). (\(node))")
        }
        type = elementName
        properties = try PropertyHelper.deserializeSupportedProperties(properties: element.availableProperties, in: node)
        parentModuleImport = element.parentModuleImport

        self.type = type
        // FIXME The name has to be done some other way
        let name = try node.value(ofAttribute: "name") as String
        self.styleName = name
        let extendedStyles = (node.value(ofAttribute: "extend") as String?)?.components(separatedBy: " ") ?? []
        self.groupName = groupName
        if let groupName = groupName {
            self.name = ":\(groupName):\(name)"
            self.extend = extendedStyles.map {
                                if $0.contains(":") {
                                    return $0
                                } else {
                                    return ":\(groupName):\($0)"
                                }
                            }
        } else {
            self.name = name
            self.extend = extendedStyles
        }
        self.properties = properties
    }

    public static func deserialize(_ node: XMLElement) throws -> Style {
        return try Style(node: node, groupName: nil)
    }
}

extension Sequence where Iterator.Element == Style {
    public func resolveStyle(for element: UIElement) throws -> [Property] {
        guard !element.styles.isEmpty else { return element.properties }
        guard let type = ElementaryDearWatson.elementMapping.first(where: { $0.value == type(of: element) })?.key else {
            print("// No type found for \(element)")
            return element.properties
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: element.properties.count)
        for name in element.styles {
            for property in try resolveStyle(for: type, named: name) {
                result[property.attributeName] = property
            }
        }
        for property in element.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }

    public func resolveStyle(for type: String, named name: String) throws -> [Property] {
        guard let style = first(where: { $0.type == type && $0.name == name }) else {
            // FIXME wrong type of error
            throw TokenizationError(message: "Style \(name) for type \(type) doesn't exist!")
        }

        let baseProperties = try style.extend.flatMap { base in
            try resolveStyle(for: type, named: base)
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: style.properties.count)
        for property in baseProperties + style.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }
}
