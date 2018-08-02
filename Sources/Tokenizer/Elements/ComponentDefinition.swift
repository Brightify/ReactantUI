//
//  Element+Root.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public protocol ComponentDefinitionContainer {
    var componentTypes: [String] { get }

    var componentDefinitions: [ComponentDefinition] { get }
}

public enum AccessModifier: String {
    case `public`
    case `internal`
}

/**
 * Contains the structure of a Component's file.
 */
public struct ComponentDefinition: XMLElementDeserializable, UIContainer, UIElementBase, StyleContainer, ComponentDefinitionContainer {
    public var type: String
    public var isRootView: Bool
    public var styles: [Style]
    public var stylesName: String
    public var children: [UIElement]
    public var edgesForExtendedLayout: [RectEdge]
    public var isAnonymous: Bool
    public var modifier: AccessModifier

    public var properties: [Property]
    public var toolingProperties: [String: Property]

    public static var parentModuleImport: String {
        return "Reactant"
    }

    public var requiredImports: Set<String> {
        return Set(arrayLiteral: "Reactant").union(children.flatMap { $0.requiredImports })
    }

    public var componentTypes: [String] {
        return [type] + ComponentDefinition.componentTypes(in: children)
    }

    public var componentDefinitions: [ComponentDefinition] {
        return [self] + ComponentDefinition.componentDefinitions(in: children)
    }

    public var addSubviewMethod: String {
        return "addSubview"
    }

    #if canImport(UIKit)
    /**
     * **[LiveUI]** Adds a `UIView` to the passed self.
     * - parameter subview: view to be added as a subview
     * - parameter toInstanceOfSelf: parent to which the view should be added
     */
    public func add(subview: UIView, toInstanceOfSelf: UIView) {
        toInstanceOfSelf.addSubview(subview)
    }
    #endif

    public init(node: XMLElement, type: String) throws {
        self.type = type
        styles = try node.singleOrNoElement(named: "styles")?.xmlChildren.compactMap { try $0.value() as Style } ?? []
        stylesName = try node.singleOrNoElement(named: "styles")?.attribute(by: "name")?.text ?? "Styles"
        children = try View.deserialize(nodes: node.xmlChildren)
        isRootView = node.value(ofAttribute: "rootView") ?? false
        if isRootView {
            edgesForExtendedLayout = (node.attribute(by: "extend")?.text).map(RectEdge.parse) ?? []
        } else {
            if node.attribute(by: "extend") != nil {
                Logger.instance.warning("Using `extend` without specifying `rootView=true` is redundant.")
            }
            edgesForExtendedLayout = []
        }
        isAnonymous = node.value(ofAttribute: "anonymous") ?? false
        if let modifier = node.value(ofAttribute: "accessModifier") as String? {
            self.modifier = AccessModifier(rawValue: modifier) ?? .internal
        } else {
            self.modifier = .internal
        }

        toolingProperties = try PropertyHelper.deserializeToolingProperties(properties: ToolingProperties.componentDefinition.allProperties, in: node)
        properties = try PropertyHelper.deserializeSupportedProperties(properties: View.availableProperties, in: node)

        // here we gather all the constraints' fields that do not have a condition and check if any are duplicate
        // in that case we warn the user about it, because it's probably not what they intended
        let fields = children.flatMap({ $0.layout.constraints.compactMap({ return $0.condition == nil ? $0.field : nil }) }).sorted()
        for (index, field) in fields.enumerated() {
            let nextIndex = index + 1
            guard nextIndex < fields.count else { break }
            if field == fields[nextIndex] {
                Logger.instance.warning("Duplicate constraint names for name \"\(field)\". The project will be compilable, but the behavior might be unexpected.")
            }
        }
    }

    /**
     * Try to deserialize a `ComponentDefinition` from an XML element.
     * - parameter node: XML element to try to parse
     * - returns: if not thrown, then the `ComponentDefinition` representing the XML element passed
     */
    public static func deserialize(_ node: SWXMLHash.XMLElement) throws -> ComponentDefinition {
        return try ComponentDefinition(node: node, type: node.value(ofAttribute: "type"))
    }
}

extension ComponentDefinition {
    static func componentTypes(in elements: [UIElement]) -> [String] {
        return elements.flatMap { element -> [String] in
            switch element {
            case let container as ComponentDefinitionContainer:
                return container.componentTypes
            case let container as UIContainer:
                return componentTypes(in: container.children)
            default:
                return []
            }
        }
    }

    static func componentDefinitions(in elements: [UIElement]) -> [ComponentDefinition] {
        return elements.flatMap { element -> [ComponentDefinition] in
            switch element {
            case let container as ComponentDefinitionContainer:
                return container.componentDefinitions
            case let container as UIContainer:
                return componentDefinitions(in: container.children)
            default:
                return []
            }
        }
    }
}

public final class ComponentDefinitionToolingProperties: PropertyContainer {
    public let preferredSize: ValuePropertyDescription<PreferredSize>

    public required init(configuration: Configuration) {
        preferredSize = configuration.property(name: "tools:preferredSize")
        super.init(configuration: configuration)
    }
}

