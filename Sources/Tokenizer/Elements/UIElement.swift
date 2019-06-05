//
//  UIElement.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

#if canImport(UIKit)
import UIKit
#endif

public struct ResolvedHyperViewAction {
    public var name: String
    public var parameters: [Parameter]
    public var sources: [Source]

    #if canImport(SwiftCodeGen)
    public func observeSources(context: ComponentContext, actionPublisher: Expression) throws -> Block {
        var block = Block()

        let actionCase = Expression.constant(".\(name)")

        for source in sources {
            let actionArguments = parameters.map { parameter -> MethodArgument in
                switch parameter.kind {
                case .constant(let value):
                    let context = SupportedPropertyTypeContext(parentContext: context, value: .value(value))
                    return MethodArgument(name: parameter.label, value: value.generate(context: context))
                case .local(let name, _):
                    return MethodArgument(name: parameter.label, value: .constant(name))
                case .reference(let view, let property?, _):
                    return MethodArgument(name: parameter.label, value: .member(target: .constant(view), name: property))
                case .reference(let view, nil, _):
                    return MethodArgument(name: parameter.label, value: .constant(view))
                case .state(let property, _):
                    return MethodArgument(name: parameter.label, value: .member(target: .constant("state"), name: property))
                }
            }

            let handler = UIElementActionObservationHandler(
                publisher: .expression(.invoke(target: .member(target: actionPublisher, name: "publish"), arguments: [
                    MethodArgument(name: "action", value: actionArguments.isEmpty ? actionCase : .invoke(target: actionCase, arguments: actionArguments))
                ])),
                captures: parameters.compactMap { parameter in
                    switch parameter.kind {
                    case .constant, .local:
                        return nil
                    case .reference(let view, _, _):
                        return "unowned \(view)"
                    case .state:
                        return "state"
                    }
                },
                innerParameters: source.action.parameters.enumerated().map { index, parameter in
                    parameter.label ?? "param\(index + 1)"
                })

            if let element = source.element as? UIElement {
                block += try source.action.observe(on: .constant(element.id.description), handler: handler)
            } else {
                #warning("FIXME: We shouldn't assume that nonconformity to UIElement means it's the parent component!")
                block += try source.action.observe(on: .constant("self"), handler: handler)
            }
        }

        return block
    }
    #endif

    public struct Source {
        public var actionName: String
        public var element: UIElementBase
        public var action: UIElementAction
        public var parameters: [Parameter]
    }

    public struct Parameter {
        public var label: String?
        public var kind: Kind
        public var type: SupportedActionType {
            switch kind {
            case .local(_, let type), .reference(_, _, let type), .state(_, let type):
                return type
            case .constant(let value):
                return .propertyType(Swift.type(of: value))
            }
        }

        public enum Kind {
            case local(name: String, type: SupportedActionType)
            case reference(view: String, property: String?, type: SupportedActionType)
            case state(property: String, type: SupportedActionType)
            case constant(value: SupportedPropertyType)
        }
    }
}

public enum SupportedActionType: Equatable {
    case propertyType(SupportedPropertyType.Type)
    case componentAction(component: String)
    case elementReference(RuntimeType)

    public func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        switch self {
        case .propertyType(let type):
            return type.runtimeType(for: platform)
        case .componentAction(let component):
            return RuntimeType(name: "\(component).Action")
        case .elementReference(let type):
            return type
        }
    }

    public static func ==(lhs: SupportedActionType, rhs: SupportedActionType) -> Bool {
        switch (lhs, rhs) {
        case (.propertyType(let lhs), .propertyType(let rhs)):
            return lhs == rhs
        case (.componentAction(let lhs), .componentAction(let rhs)):
            return lhs == rhs
        case (.elementReference(let lhs), .elementReference(let rhs)):
            return lhs == rhs
        default:
            return false
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

#if canImport(SwiftCodeGen)
public struct UIElementActionObservationHandler {
    let publisher: Statement
    let innerParameters: [String]
    let captures: [String]

    var listener: Closure {
        return Closure(
            captures: captures,
            parameters: innerParameters,
            block: [
                publisher,
            ])
    }

    init(publisher: Statement, captures: [String], innerParameters: [String]) {
        self.publisher = publisher
        self.captures = captures
        self.innerParameters = innerParameters
    }
}
#endif

public protocol UIElementAction {
    typealias Parameter = (label: String?, type: SupportedActionType)

    var primaryName: String { get }

    var aliases: Set<String> { get }

    var parameters: [Parameter] { get }

    func matches(action: HyperViewAction) -> Bool

    #if canImport(SwiftCodeGen)
    func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement
    #endif
}

public extension UIElementAction {
    func matches(action: HyperViewAction) -> Bool {
        return primaryName == action.eventName || aliases.contains(action.eventName)
    }
}

public class ViewTapAction: UIElementAction {
    public let primaryName = "tap"

    public let aliases: Set<String> = []

    public let parameters: [Parameter] = []

    #if canImport(SwiftCodeGen)
    public func observe(on view: Expression, handler: UIElementActionObservationHandler) throws -> Statement {
        return .expression(.invoke(target: .constant("GestureRecognizerObserver.bindTap"), arguments: [
            MethodArgument(name: "to", value: view),
            MethodArgument(name: "handler", value: .closure(handler.listener)),
        ]))
    }
    #endif
}

/**
 * The most basic UI element protocol that every UI element should conform to.
 * UI elements usually conform to this protocol through `UIElement` or `View`.
 * Allows for more customization than conforming to `UIElement` directly.
 */
public protocol UIElementBase {
    var properties: [Property] { get set }
    var toolingProperties: [String: Property] { get set }
    var handledActions: [HyperViewAction] { get set }

    // used for generating styles - does not care about children imports
    static var parentModuleImport: String { get }

    // used for generating views - resolves imports of subviews.
    var requiredImports: Set<String> { get }

    func supportedActions(context: ComponentContext) throws -> [UIElementAction]

}

public struct StateProperty {
    public var name: String
    public var type: SupportedPropertyType.Type
    public var property: Property
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
    var factory: UIElementFactory { get }

    var id: UIElementID { get }
    var isExported: Bool { get }
    var layout: Layout { get set }
    var styles: [StyleName] { get set }

    static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }
    static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }

    static func runtimeType() throws -> String

    func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType
}

extension UIElement {
    public static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (ConstraintPriority.high, ConstraintPriority.high)
    }
    public static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (ConstraintPriority.low, ConstraintPriority.low)
    }
}

#if canImport(SwiftCodeGen)
public protocol ProvidesCodeInitialization {
    func initialization(for platform: RuntimePlatform) throws -> Expression
}
#endif

#if canImport(UIKit)
public protocol CanInitializeUIKitView {
    func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView
}
#endif
