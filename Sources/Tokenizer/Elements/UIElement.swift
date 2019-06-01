//
//  UIElement.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

import SwiftCodeGen

public struct ResolvedHyperViewAction {
    public var name: String
    public var parameters: [Parameter]
//    public var sources: [Source]

    public struct Source {
        public var parameters: [Parameter]
    }

    public struct Parameter {
        public var label: String?
        public var kind: Kind
        public var type: SupportedPropertyType.Type {
            switch kind {
            case .reference(let type):
                return type
            case .constant(let value):
                return Swift.type(of: value)
            }
        }

        public enum Kind {
//            case inheritedParameters()
            case reference(type: SupportedPropertyType.Type)
            case constant(value: SupportedPropertyType)
        }
    }
}

public struct HyperViewAction {
    public var name: String
    public var eventName: String
    public var parameters: [(label: String?, parameter: Parameter)]

    public enum Parameter {
        case inheritedParameters
        case constant(type: String, value: String)
        case stateVariable(name: String)
        case reference(targetId: String, property: String?)
    }

    public init(name: String, eventName: String, parameters: [(label: String?, parameter: Parameter)]) {
        self.name = name
        self.eventName = eventName
        self.parameters = parameters
    }

    public init?(attribute: XMLAttribute) throws {
        let prefix = "action:"
        guard attribute.name.starts(with: prefix) else { return nil }

        eventName = String(attribute.name.dropFirst(prefix.count))

        self = try ActionParser(tokens: Lexer.tokenize(input: attribute.text)).parseAction(eventName: eventName)
    }
}

/**
 * The most basic UI element protocol that every UI element should conform to.
 * UI elements usually conform to this protocol through `UIElement` or `View`.
 * Allows for more customization than conforming to `UIElement` directly.
 */
public protocol UIElementBase {
    var properties: [Property] { get set }
    var toolingProperties: [String: Property] { get set }

    // used for generating styles - does not care about children imports
    static var parentModuleImport: String { get }

    // used for generating views - resolves imports of subviews.
    var requiredImports: Set<String> { get }
}

public struct StateProperty {
    public var name: String
    public var type: SupportedPropertyType.Type
    public var property: Tokenizer.Property
}

public extension UIElementBase {
    var allStateProperties: [(element: UIElementBase, properties: [StateProperty])] {
        let stateProperties = [(element: self as UIElementBase, properties: properties.compactMap { property -> StateProperty? in
            guard case .state(let name, let type) = property.anyValue else { return nil }
            return StateProperty(name: name, type: type, property: property)
        })]

        if let container = self as? UIContainer {
            return stateProperties + container.children.flatMap { $0.allStateProperties }
        } else {
            return stateProperties
        }
    }
}

public enum UIElementID: CustomStringConvertible, Hashable {
    case provided(String)
    case generated(String)

    public var description: String {
        switch self {
        case .provided(let id):
            return id
        case .generated(let id):
            return id
        }
    }
}

extension UIElementID: XMLAttributeDeserializable {
    public static func deserialize(_ attribute: XMLAttribute) throws -> UIElementID {
        return .provided(attribute.text)
    }
}

/**
 * Contains the interface to a real UI element (layout, styling).
 * Conforming to this protocol is sufficient on its own when creating a UI element.
 */
public protocol UIElement: AnyObject, UIElementBase, XMLElementSerializable {
    var id: UIElementID { get }
    var isExported: Bool { get }
    var layout: Layout { get set }
    var styles: [StyleName] { get set }
    var handledActions: [HyperViewAction] { get set }

    static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }
    static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }

    static func runtimeType() throws -> String

    func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType

    func initialization(for platform: RuntimePlatform, describeInto pipe: DescriptionPipe) throws

    #if canImport(UIKit)
    func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView
    #endif
}

extension UIElement {
    public static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (ConstraintPriority.high, ConstraintPriority.high)
    }
    public static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (ConstraintPriority.low, ConstraintPriority.low)
    }
}
