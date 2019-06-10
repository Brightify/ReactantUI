//
//  ComponentContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

/**
 * The "file"'s context. This context is available throughout a Component's file.
 * It's used to resolve local styles and delegate global style resolving to global context.
 */
public class ComponentContext: DataContext {
    public let globalContext: GlobalContext
    public let component: ComponentDefinition

    public init(globalContext: GlobalContext, component: ComponentDefinition) {
        self.globalContext = globalContext
        self.component = component
    }

    public func resolvedStyleName(named styleName: StyleName) -> String {
        guard case .local(let name) = styleName else {
            return globalContext.resolvedStyleName(named: styleName)
        }
        return component.stylesName + "Styles." + name
    }

    public func style(named styleName: StyleName) -> Style? {
        guard case .local(let name) = styleName else {
            return globalContext.style(named: styleName)
        }
        return component.styles.first { $0.name.name == name }
    }

    public struct ResolvedStateItem {
        public var name: String
        public var type: SupportedPropertyType.Type
        public var defaultValue: SupportedPropertyType
        public var applications: [Application]

        public struct Application {
            public var element: UIElementBase
            public var property: StateProperty
        }
    }

    public func resolve(state: ComponentDefinition) throws -> [String: ResolvedStateItem] {
        let extraStateProperties = try state.allChildren.map { child -> (element: UIElementBase, properties: [StateProperty]) in
            let props = try self.stateProperties(of: child).compactMap { property -> StateProperty? in
                guard case .state(let name, let type) = property.anyValue else { return nil }
                return StateProperty(name: name, type: type, property: property)
            }
            return (element: child, properties: props)
        }
        let stateProperties = (state.allStateProperties + extraStateProperties).flatMap { element, properties in
            properties.map { (element: element, property: $0) }
        }

        let applicationsToVerify: [String: [ResolvedStateItem.Application]] = Dictionary(grouping: stateProperties.map { element, property in
            ResolvedStateItem.Application(element: element, property: property) //name: property.name, type: property.type, defaultValue: property.property.anyDescription.anyDefaultValue, element: element)
        }, by: { $0.property.name })

        for (name, applications) in applicationsToVerify {
            guard let firstApplication = applications.first else { continue }
            let verificationResult = applications.dropFirst().allSatisfy { application in
                firstApplication.property.type == application.property.type
            }

            #warning("FIXME Improve error reporting")
            guard verificationResult else {
                throw TokenizationError(message: "Incompatible state item found for name: \(name)!")
            }
        }

        return applicationsToVerify.mapValues { applications in
            let firstApplication = applications.first!
            return ResolvedStateItem(
                name: firstApplication.property.name,
                type: firstApplication.property.type,
                defaultValue: firstApplication.property.property.anyDescription.anyDefaultValue,
                applications: applications)
        }
    }

    public func resolve(actions: [(element: UIElementBase, actions: [HyperViewAction])]) throws -> [ResolvedHyperViewAction] {
        let elementActions: [(element: UIElementBase, action: HyperViewAction, elementAction: UIElementAction)] = try actions.flatMap { element, actions in
            try actions.compactMap { action in
                guard let elementAction = try element.supportedActions(context: self).first(where: { $0.matches(action: action) }) else { return nil }
                return (element: element, action: action, elementAction: elementAction)
            }
        }

        #warning("Compute state once in init, not here for improved performance")
        let state = try resolve(state: component)

        let sourcesToVerify: [String: [ResolvedHyperViewAction.Source]] = try Dictionary(grouping: elementActions.map { element, action, elementAction in
            let parameters = try action.parameters.flatMap { label, parameter -> [ResolvedHyperViewAction.Parameter] in
                switch parameter {
                case .inheritedParameters:
                    return elementAction.parameters.enumerated().map { index, parameter in
                        let (label, type) = parameter
                        return ResolvedHyperViewAction.Parameter(label: label, kind: .local(name: label ?? "param\(index + 1)", type: type))
                    }
                case .constant(let type, let value):
                    guard let foundType = RuntimePlatform.iOS.supportedTypes.first(where: {
                        $0.runtimeType(for: .iOS).name == type && $0 is AttributeSupportedPropertyType.Type
                    }) as? AttributeSupportedPropertyType.Type else {
                        throw TokenizationError(message: "Unknown type \(type) for value \(value)")
                    }

                    let typedValue = try foundType.materialize(from: value)

                return [ResolvedHyperViewAction.Parameter(label: label, kind: .constant(value: typedValue))]
//                    return ResolvedHyperViewAction.Parameter(label: label, kind: .constant(value:     ))
                case .stateVariable(let name):
                    return [ResolvedHyperViewAction.Parameter(label: label, kind: .state(property: name, type: .propertyType(state[name]!.type)))]
                case .reference(var targetId, let propertyName):
                    let targetElement: UIElement
                    if targetId == "self" {
                        guard let foundTargetElement = element as? UIElement else {
                            throw TokenizationError(message: "Using `self` as target on non-UIElement is not yet supported!")
                        }
                        targetElement = foundTargetElement
                        targetId = targetElement.id.description
                    } else {
                        guard let foundTargetElement = component.allChildren.first(where: { $0.id.description == targetId }) else {
                            throw TokenizationError(message: "Element with id \(targetId) doesn't exist in \(component.type)!")
                        }
                        targetElement = foundTargetElement
                    }

                    if let propertyName = propertyName {
                        guard let property = targetElement.factory.availableProperties.first(where: { $0.name == propertyName }) else {
                            throw TokenizationError(message: "Element with id \(targetId) used in \(component.type) doesn't have property named \(propertyName).!")
                        }
                        return [ResolvedHyperViewAction.Parameter(label: label, kind: .reference(view: targetId, property: propertyName, type: .propertyType(property.type)))]
                    } else {
                        return try [ResolvedHyperViewAction.Parameter(label: label, kind: .reference(view: targetId, property: nil, type: .elementReference(targetElement.runtimeType(for: .iOS))))]
                    }
                }
            }

            return ResolvedHyperViewAction.Source(actionName: action.name, element: element, action: elementAction, parameters: parameters)
        }, by: { $0.actionName })

        for (name, actions) in sourcesToVerify {
            guard let firstAction = actions.first else { continue }
            let verificationResult = actions.dropFirst().allSatisfy { action in
                guard action.parameters.count == firstAction.parameters.count else { return false }

                return action.parameters.enumerated().allSatisfy { index, parameter in
                    let firstActionParameter = firstAction.parameters[index]
                    return firstActionParameter.type == parameter.type
                }
            }

            #warning("FIXME Improve error reporting")
            guard verificationResult else {
                throw TokenizationError(message: "Incompatible actions found for name: \(name)!")
            }
        }

        return sourcesToVerify.map { name, sources in
            ResolvedHyperViewAction(name: name, parameters: sources.first!.parameters, sources: sources)
        }

//        return actionsToVerify.values.flatMap { $0 }

//        return [
//            ResolvedHyperViewAction(name: "a", parameters: [
//                ResolvedHyperViewAction.Parameter(label: "abc", kind: .constant(value: 100)),
//                ResolvedHyperViewAction.Parameter(label: "efg", kind: .reference(type: TransformedText.self))
//            ])
//        ]


//        action.parameters.map { label, parameter -> ResolvedHyperViewAction.Parameter in
//            switch parameter {
//            case .inheritedParameters:
//                break
//            case .constant(let type, let value):
//                break
//            case .stateVariable(let name):
//                break
//            case .reference(let targetId, let property):
//                break
//            }
//        }
    }

    /// Returns any state properties
    public func stateProperties(of element: UIElement) throws -> [Property] {
        #warning("FIXME This is extra hacky, it should be better to have a proper API for this")
        if let reference = element as? ComponentReference {
            let definition = try reference.definition ?? globalContext.definition(for: reference.type)
            let state = try resolve(state: definition)

            return try reference.possibleStateProperties.map { name, value -> Property in
                guard let stateProperty = state[name] else {
                    throw TokenizationError(message: "Element \(element) doesn't have a state property \(name)!")
                }

                let propertyValue: AnyPropertyValue
                if value.starts(with: "$") {
                    propertyValue = .state(String(value.dropFirst()), stateProperty.type)
                } else if let attributeType = stateProperty.type as? AttributeSupportedPropertyType.Type {
                    propertyValue = try .value(attributeType.materialize(from: value))
                } else {
                    throw TokenizationError(message: "Property type \(stateProperty.type) not yet supported for state properties!")
                }

                return _StateProperty(namespace: [PropertyContainer.Namespace(name: "state", isOptional: false)], name: name, anyDescription:
                    _StateProperty.Description(name: name, namespace: [], type: stateProperty.type, anyDefaultValue: stateProperty.defaultValue), anyValue: propertyValue)
            }
        } else {
            return []
        }
    }
    
    public func child(for definition: ComponentDefinition) -> ComponentContext {
        return ComponentContext(globalContext: globalContext, component: definition)
    }
}

extension ComponentContext: HasGlobalContext { }

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

#if canImport(UIKit)
import UIKit
#endif

private struct _StateProperty: Property {
    struct Description: PropertyDescription {
        var name: String
        var namespace: [PropertyContainer.Namespace]
        var type: SupportedPropertyType.Type
        var anyDefaultValue: SupportedPropertyType
    }

    public var namespace: [PropertyContainer.Namespace]
    public var name: String
    public let anyDescription: PropertyDescription
    public var anyValue: AnyPropertyValue

    public var attributeName: String {
        return namespace.resolvedAttributeName(name: name)
    }

    #if canImport(SwiftCodeGen)
    /**
     * - parameter context: property context to use
     * - returns: Swift `String` representation of the property application on the target
     */
    public func application(context: PropertyContext) -> Expression {
        return anyValue.generate(context: context.child(for: anyValue))
    }

    /**
     * - parameter target: UI element to be targetted with the property
     * - parameter context: property context to use
     * - returns: Swift `String` representation of the property application on the target
     */
    public func application(on target: String, context: PropertyContext) -> Statement {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)

        return .assignment(target: .member(target: .constant(namespacedTarget), name: name), expression: application(context: context))
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: PropertyContext) -> XMLSerializableAttribute {
        return XMLSerializableAttribute(name: attributeName, value: value.dematerialize(context: context.child(for: value)))
    }
    #endif

    #if canImport(UIKit)
    /**
     * Try to apply the property on an object using the passed property context.
     * - parameter object: UI element to apply the property to
     * - parameter context: property context to use
     */
    public func apply(on object: AnyObject, context: PropertyContext) throws {
        guard let target = object as? LiveHyperViewBase else {
            throw LiveUIError(message: "_StateProperty application is available only on instances of `LiveHyperViewBase`. Used \(object)!")
        }

        try target.stateProperties[name]?.set(value: anyValue.runtimeValue(context: context.child(for: anyValue)))

//        let name = anyDescription.name
//        let selector = Selector("set\(name.capitalizingFirstLetter()):")
//
//        let target = try resolveTarget(for: object)
//
//        guard target.responds(to: selector) else {
//            throw LiveUIError(message: "!! Object `\(target)` doesn't respond to selector `\(name)` to set value `\(anyValue)`")
//        }
//        guard let resolvedValue = anyValue.runtimeValue(context: context.child(for: name)) else {
//            throw LiveUIError(message: "!! Value `\(anyValue)` couldn't be resolved in runtime for key `\(key)`")
//        }
//
//        do {
//            try catchException {
//                _ = target.setValue(resolvedValue, forKey: name)
//            }
//        } catch {
//            _ = target.perform(selector, with: resolvedValue)
//        }

    }

    private func resolveTarget(for object: AnyObject) throws -> AnyObject {
        if namespace.isEmpty {
            return object
        } else {
            let keyPath = namespace.resolvedKeyPath
            guard let target = object.value(forKeyPath: keyPath) else {
                throw LiveUIError(message: "!! Object \(object) doesn't have keyPath \(keyPath) to resolve real target")
            }
            return target as AnyObject
        }
    }
    #endif
}
