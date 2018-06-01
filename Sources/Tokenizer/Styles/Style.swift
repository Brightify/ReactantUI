//
//  Style.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if ReactantRuntime
import Reactant
#endif

public enum Style: XMLElementDeserializable {
    case view(ViewStyle)
    case attributedText(AttributedTextStyle)

    public var properties: [Property] {
        switch self {
        case .view(let viewStyle):
            return viewStyle.properties
        case .attributedText(let attributedStyle):
            return attributedStyle.properties
        }
    }

    public var parentModuleImport: String {
        switch self {
        case .view(let viewStyle):
            return viewStyle.parentModuleImport
        case .attributedText(let attributedStyle):
            return attributedStyle.parentModuleImport
        }
    }

    public var styleType: String {
        switch self {
        case .view(let viewStyle):
            return viewStyle.type
        case .attributedText:
            return "attributedText"
        }
    }

    public var name: String {
        switch self {
        case .view(let viewStyle):
            return viewStyle.name
        case .attributedText(let attributedStyle):
            return attributedStyle.name
        }
    }

    public var extend: [String] {
        switch self {
        case .view(let viewStyle):
            return viewStyle.extend
        case .attributedText(let attributedStyle):
            return attributedStyle.extend
        }
    }

    init(node: XMLElement, groupName: String?) throws {
        if node.name == "attributedTextStyle" {
            self = try .attributedText(AttributedTextStyle(node: node, groupName: groupName))
        } else if let (elementName, element) = ElementMapping.mapping.first(where: { node.name == "\($0.key)Style" }) {
            self = try .view(ViewStyle(node: node, elementName: elementName, element: element, groupName: groupName))
        } else {
            throw TokenizationError(message: "Unknown style \(node.name). (\(node))")
        }
    }

    public static func deserialize(_ element: XMLElement) throws -> Style {
        return try Style(node: element, groupName: nil)
    }
}

public struct ViewStyle {
    public var type: String
    // name within group
    public var name: String
    // name of the style without group name
    public var styleName: String
    public var extend: [String]
    public var properties: [Property]
    public var groupName: String?

    public var parentModuleImport: String

    init(node: XMLElement, elementName: String, element: View.Type, groupName: String? = nil) throws {
        let properties: [Property]

        properties = try PropertyHelper.deserializeSupportedProperties(properties: element.availableProperties, in: node)
        parentModuleImport = element.parentModuleImport

        type = elementName
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
}

public struct AttributedTextStyle {
    // name within group
    public var name: String
    // name of the style without group name
    public var styleName: String
    public var extend: [String]
    public var properties: [Property]
    public var groupName: String?

    public var parentModuleImport: String {
        return "Reactant"
    }

    init(node: XMLElement, groupName: String? = nil) throws {
        let properties: [Property]

        properties = try PropertyHelper.deserializeSupportedProperties(properties: Properties.attributedText.allProperties, in: node)

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
}

extension Sequence where Iterator.Element == Style {
    public func resolveStyle(for element: UIElement) throws -> [Property] {
        guard !element.styles.isEmpty else { return element.properties }
        guard let type = ElementMapping.mapping.first(where: { $0.value == type(of: element) })?.key else {
            print("// No type found for \(element)")
            return element.properties
        }
        let viewStyles = compactMap { style -> ViewStyle? in
            if case .view(let viewStyle) = style {
                return viewStyle
            } else {
                return nil
            }
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: element.properties.count)
        for name in element.styles {
            for property in try viewStyles.resolveStyle(for: type, named: name) {
                result[property.attributeName] = property
            }
        }
        for property in element.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }
}

extension Sequence where Iterator.Element == ViewStyle {
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
