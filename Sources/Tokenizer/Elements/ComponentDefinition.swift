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
public struct ComponentDefinition: UIContainer, UIElementBase, StyleContainer, ComponentDefinitionContainer {
    public var type: String
    public var isRootView: Bool
    public var styles: [Style]
    public var stylesName: String
    public var templates: [Template]
    public var templatesName: String
    public var children: [UIElement]
    public var edgesForExtendedLayout: [RectEdge]
    public var isAnonymous: Bool
    public var modifier: AccessModifier
    public var handledActions: [HyperViewAction]
    public var properties: [Property]
    public var toolingProperties: [String: Property]
    
    public static var parentModuleImport: String {
        return "Hyperdrive"
    }

    public var requiredImports: Set<String> {
        return Set(arrayLiteral: "Hyperdrive").union(children.flatMap { $0.requiredImports })
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

    public init(context: ComponentDeserializationContext) throws {
        let node = context.element
        type = context.type
        styles = try node.singleOrNoElement(named: "styles")?.xmlChildren.compactMap { try context.deserialize(element: $0, groupName: nil) } ?? []
        stylesName = try node.singleOrNoElement(named: "styles")?.attribute(by: "name")?.text ?? "Styles"
        templates = try node.singleOrNoElement(named: "templates")?.xmlChildren.compactMap { try $0.value() as Template } ?? []
        templatesName = try node.singleOrNoElement(named: "templates")?.attribute(by: "name")?.text ?? "Templates"
        children = try node.xmlChildren.compactMap(context.deserialize(element:))
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
        handledActions = try node.allAttributes.compactMap { _, value in
            try HyperViewAction(attribute: value)
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
}

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public class ComponentDefinitionAction: UIElementAction {
    public let primaryName: String

    public let aliases: Set<String> = []

    public let parameters: [Parameter]

    init(action: ResolvedHyperViewAction) {
        primaryName = action.name
        parameters = action.parameters.map { parameter in
            Parameter(label: parameter.label, type: parameter.type)
        }
    }

    #if canImport(SwiftCodeGen)
    public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
        let listener = Closure(captures: handler.captures, parameters: [(name: "action", type: nil)], block: [
            .if(condition: [.enumUnwrap(case: primaryName, parameters: handler.innerParameters, expression: .constant("action"))], then: [handler.publisher], else: nil)
            ])

        return .expression(.invoke(target: .member(target: view, name: "actionPublisher.listen"), arguments: [
            MethodArgument(name: "with", value: .closure(listener)),
        ]))
    }
    #endif
}

extension ComponentDefinition {
    public func supportedActions(context: ComponentContext) throws -> [UIElementAction] {
//        let resolvedActions = try context.resolve(actions: providedActions)
//
//        let actions = resolvedActions.map { action in
//            ComponentDefinitionAction(action: action)
//        }
        return [
            ViewTapAction(),
        ]
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
        preferredSize = configuration.property(name: "tools:preferredSize", defaultValue: PreferredSize(width: .fill, height: .wrap))
        super.init(configuration: configuration)
    }
}

