//
//  Template.swift
//  Example
//
//  Created by Robin Krenecky on 05/10/2018.
//

import Foundation
#if canImport(UIKit)
import Reactant
#endif

public protocol XMLAttributeName {
    init(from value: String) throws
}

/**
 * Template identifier used to resolve the template name.
 */
public enum TemplateName: XMLAttributeDeserializable, XMLAttributeName {
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
            throw TokenizationError.invalidTemplateName(text: value)
        }
    }

    /**
     * Generates an XML `String` representation of the `TemplateName`.
     * - returns: XML `String` representation of the `TemplateName`
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
     * Tries to parse the passed XML attribute into a `TemplateName` identifier.
     * - parameter attribute: XML attribute to be parsed into `TemplateName`
     * - returns: if not thrown, the parsed `TemplateName`
     */
    public static func deserialize(_ attribute: XMLAttribute) throws -> TemplateName {
        return try TemplateName(from: attribute.text)
    }
}

extension TemplateName: Equatable {
    public static func == (lhs: TemplateName, rhs: TemplateName) -> Bool {
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

extension Array: XMLAttributeDeserializable where Iterator.Element: XMLAttributeName {
    public static func deserialize(_ attribute: XMLAttribute) throws -> Array {
        let names = attribute.text.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter {
            !$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
        }

        return try names.map {
            try Iterator.Element(from: $0)
        }
    }
}

/**
 * Structure representing an XML template.
 *
 * Example:
 * ```
 *  <templates>
 *      <attributedString style="attributedStyle" name="superTemplate">
 *          <b>Hello</b> {{name}}, {{foo}}
 *      </attributedString>
 *  </templates>
 * ```
 */
public struct Template: XMLElementDeserializable {
    public var name: TemplateName
    public var extend: [TemplateName]
    public var parentModuleImport: String
    public var properties: [Property]
    public var type: TemplateType

    init(node: XMLElement, groupName: String?) throws {
        let name = try node.value(ofAttribute: "name") as String
        let extendedStyles = try node.value(ofAttribute: "extend", defaultValue: []) as [TemplateName]
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

        if node.name == "attributedString" {
            parentModuleImport = "Reactant"
            properties = try PropertyHelper.deserializeSupportedProperties(properties: Properties.attributedText.allProperties, in: node) as [Property]
            type = .attributedText(template: try AttributedTextTemplate(node: node))
        } else {
            throw TokenizationError(message: "Unknown template \(node.name). (\(node))")
        }
    }

    /**
     * Checks if any of Template's properties require theming.
     * - parameter context: context to use
     * - returns: `Bool` whether or not any of its properties require theming
     */
    public func requiresTheme(context: DataContext) -> Bool {
        return properties.contains(where: { $0.anyValue.requiresTheme }) ||
            extend.contains(where: {
                context.template(named: $0)?.requiresTheme(context: context) == true
            })
    }

    /**
     * Tries to create the `Template` structure from an XML element.
     * - parameter element: XML element to parse
     * - returns: if not thrown, `Template` obtained from the passed XML element
     */
    public static func deserialize(_ element: XMLElement) throws -> Template {
        return try Template(node: element, groupName: nil)
    }
}

/**
 * Represents `Template`'s type.
 * Currently, there are:
 * - attributedText: attributed string styling allowing multiple attributed style tags with custom arguments to be defined within it
 */
public enum TemplateType {
    case attributedText(template: AttributedTextTemplate)

    public var styleType: String {
        switch self {
        case .attributedText:
            return "attributedText"
        }
    }
}

public struct AttributedTextTemplate {
    public var attributedText: ElementAssignableProperty<AttributedText>
    public var arguments: [String]

    init(node: XMLElement) throws {
        let text = try AttributedText.materialize(from: node)
        let description = "attributedText"
        attributedText = ElementAssignableProperty(namespace: [],
                                                   name: description,
                                                   description: ElementAssignablePropertyDescription(
                                                    namespace: [], name: description,
                                                    swiftName: description, key: description),
                                                   value: text)
        arguments = []
        node.children.forEach {
            let tokens = Lexer.tokenize(input: $0.description)
            tokens.forEach { token in
                if case .argument(let argument) = token, !arguments.contains(argument) {
                    arguments.append(argument)
                }
            }
        }
    }
}
