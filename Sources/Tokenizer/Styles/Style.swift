//
//  Style.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import Hyperdrive
#endif

/**
 * Style identifier used to resolve the style name.
 */
public enum StyleName: XMLAttributeDeserializable, XMLAttributeName {
    case local(name: String)
    case global(group: String, name: String)

    /**
     * Gets the `name` variable from either of the cases.
     */
    public var name: String {
        switch self {
        case .local(let name):
            return name
        case .global(_, let name):
            return name
        }
    }

    public init(from value: String) throws {
        let notationCharacter: String
        if value.contains(".") {
            notationCharacter = "."
        } else {
            notationCharacter = ":"
        }

        let components = value.components(separatedBy: notationCharacter).filter { !$0.isEmpty }
        if components.count == 2 {
            self = .global(group: components[0], name: components[1])
        } else if components.count == 1 {
            self = .local(name: components[0])
        } else {
            throw TokenizationError.invalidStyleName(text: value)
        }
    }

    /**
     * Generates an XML `String` representation of the `StyleName`.
     * - returns: XML `String` representation of the `StyleName`
     */
    public func serialize() -> String {
        switch self {
        case .local(let name):
            return name
        case .global(let group, let name):
            return ":\(group):\(name)"
        }
    }

    /**
     * Tries to parse the passed XML attribute into a `StyleName` identifier.
     * - parameter attribute: XML attribute to be parsed into `StyleName`
     * - returns: if not thrown, the parsed `StyleName`
     */
    public static func deserialize(_ attribute: XMLAttribute) throws -> StyleName {
        return try StyleName(from: attribute.text)
    }
}

extension StyleName: Equatable {
    public static func ==(lhs: StyleName, rhs: StyleName) -> Bool {
        switch (lhs, rhs) {
        case (.local(let lName), .local(let rName)):
            return lName == rName
        case (.global(let lGroup, let lName), .global(let rGroup, let rName)):
            return lGroup == rGroup && lName == rName
        default:
            return false
        }
    }
}

/**
 * Structure representing an XML style.
 *
 * Example:
 * ```
 * <styles name="ReactantStyles">
 *   <LabelStyle name="base" backgroundColor="white" />
 *   <ButtonStyle name="buttona"
 *     backgroundColor.highlighted="white"
 *     isUserInteractionEnabled="true" />
 *   <attributedTextStyle name="bandaska" extend="common:globalko">
 *     <i font=":bold@20" />
 *     <base foregroundColor="white" />
 *   </attributedTextStyle>
 * </styles>
 * ```
 */
public struct Style: XMLAttributeDeserializable, XMLElementDeserializable {
    public var name: StyleName
    public var extend: [StyleName]
    public var accessModifier: AccessModifier
    public var parentModuleImport: String
    public var properties: [Property]
    public var type: StyleType

    init(node: XMLElement, groupName: String?) throws {
        let name = try node.value(ofAttribute: "name") as String
        let extendedStyles = try node.value(ofAttribute: "extend", defaultValue: []) as [StyleName]
        if let modifier = node.value(ofAttribute: "accessModifier") as String? {
            accessModifier = AccessModifier(rawValue: modifier) ?? .internal
        } else {
            accessModifier = .internal
        }
        if let groupName = groupName {
            self.name = .global(group: groupName, name: name)
            self.extend = extendedStyles.map {
                if case .local(let name) = $0 {
                    return .global(group: groupName, name: name)
                } else {
                    return $0
                }
            }
        } else {
            self.name = .local(name: name)
            self.extend = extendedStyles
        }

        if node.name == "attributedTextStyle" {
            parentModuleImport = "Hyperdrive"
            properties = try PropertyHelper.deserializeSupportedProperties(properties: Properties.attributedText.allProperties, in: node) as [Property]

            type = try .attributedText(styles: node.xmlChildren.map(AttributedTextStyle.deserialize))

        } else if let (elementName, element) = ElementMapping.mapping.first(where: { node.name == "\($0.key)Style" }) {
            parentModuleImport = element.parentModuleImport
            properties = try PropertyHelper.deserializeSupportedProperties(properties: element.availableProperties, in: node) as [Property]
            type = .view(type: elementName)
        } else {
            throw TokenizationError(message: "Unknown style \(node.name). (\(node))")
        }
    }

    /**
     * Checks if any of Style's properties require theming.
     * - parameter context: context to use
     * - returns: `Bool` whether or not any of its properties require theming
     */
    public func requiresTheme(context: DataContext) -> Bool {
        return properties.contains(where: { $0.anyValue.requiresTheme }) ||
            extend.contains(where: {
                context.style(named: $0)?.requiresTheme(context: context) == true
            })
    }

    /**
     * Tries to create the `Style` structure from an XML element.
     * - parameter element: XML element to parse
     * - returns: if not thrown, `Style` obtained from the passed XML element
     */
    public static func deserialize(_ element: XMLElement) throws -> Style {
        return try Style(node: element, groupName: nil)
    }
}

/**
 * Represents `Style`'s type.
 * Currently, there are:
 * - view: basic UI element styling
 * - attributedText: attributed string styling allowing multiple attributed style tags to be defined within it
 */
public enum StyleType {
    case view(type: String)
    case attributedText(styles: [AttributedTextStyle])

    public var styleType: String {
        switch self {
        case .view(let type):
            return type
        case .attributedText:
            return "attributedText"
        }
    }
}

/**
 * Structure representing a single tag inside an <attributedTextStyle> element within `StyleGroup` (<styles>).
 */
public struct AttributedTextStyle: XMLElementDeserializable {
    public var name: String
    public var accessModifier: AccessModifier
    public var properties: [Property]

    init(node: XMLElement) throws {
        name = node.name
        if let modifier = node.value(ofAttribute: "accessModifier") as String? {
            accessModifier = AccessModifier(rawValue: modifier) ?? .internal
        } else {
            accessModifier = .internal
        }
        properties = try PropertyHelper.deserializeSupportedProperties(properties: Properties.attributedText.allProperties, in: node) as [Property]
    }

    public static func deserialize(_ element: XMLElement) throws -> AttributedTextStyle {
        return try AttributedTextStyle(node: element)
    }
}

extension XMLElement {
    public func value<T: XMLAttributeDeserializable>(ofAttribute attr: String, defaultValue: T) throws -> T {
        if let attr = self.attribute(by: attr) {
            return try T.deserialize(attr)
        } else {
            return defaultValue
        }
    }
}

extension Sequence where Iterator.Element == Style {
    public func resolveStyle(for element: UIElement) throws -> [Property] {
        guard !element.styles.isEmpty else { return element.properties }
        guard let type = ElementMapping.mapping.first(where: { $0.value == type(of: element) })?.key else {
            print("// No type found for \(element)")
            return element.properties
        }
        let viewStyles = compactMap { style -> Style? in
            if case .view(let styledType) = style.type, styledType == type {
                return style
            } else {
                return nil
            }
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: element.properties.count)
        for name in element.styles {
            for property in try viewStyles.resolveViewStyle(for: type, named: name) {
                result[property.attributeName] = property
            }
        }
        for property in element.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }

    private func resolveViewStyle(for type: String, named name: StyleName) throws -> [Property] {
        guard let style = first(where: { $0.name == name }) else {
            // FIXME wrong type of error
            throw TokenizationError(message: "Style \(name) for type \(type) doesn't exist!")
        }

        let baseProperties = try style.extend.flatMap { base in
            try resolveViewStyle(for: type, named: base)
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: style.properties.count)
        for property in baseProperties + style.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }
}
