//
//  ElementControlStateProperty.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/**
 * Typed property obtained from an XML element.
 * It's mostly identical to the `ControlStateProperty`.
 * The difference is mostly in the code generation and property application.
 */
public struct ElementControlStateProperty<T: ElementSupportedPropertyType>: TypedProperty {
    public var namespace: [PropertyContainer.Namespace]
    public var name: String
    public var state: [ControlState]

    public var description: ElementControlStatePropertyDescription<T>
    public var value: T

    public var attributeName: String {
        let namespacedName = namespace.resolvedAttributeName(name: name)
        if state == [] || state == [.normal] {
            return namespacedName
        } else {
            return namespacedName + "." + state.name
        }
    }

    /**
     * - parameter context: property context to use
     * - returns: Swift `String` representation of the property application on the target
     */
    public func application(context: PropertyContext) -> String {
        return value.generate(context: context.child(for: value))
    }

    /**
     * - parameter target: UI element to be targetted with the property
     * - parameter context: property context to use
     * - returns: Swift `String` representation of the property application on the target
     */
    public func application(on target: String, context: PropertyContext) -> String {
        let state = parseState(from: attributeName) as [ControlState]
        let stringState = state.map { "UIControl.State.\($0.rawValue)" }.joined(separator: ", ")
        let namespacedTarget = namespace.resolvedSwiftName(target: target)
        return "\(namespacedTarget).set\(description.key.capitalizingFirstLetter())(\(application(context: context)), for: [\(stringState)])"
    }

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
        let key = description.key
        let selector = Selector("set\(key.capitalizingFirstLetter()):forState:")

        let target = try resolveTarget(for: object)

        guard target.responds(to: selector) else {
            throw LiveUIError(message: "!! Object \(target) doesn't respond to \(selector) (property: \(self))")
        }
        guard let resolvedValue = value.runtimeValue(context: context.child(for: value)) else {
            throw LiveUIError(message: "!! Value `\(value)` couldn't be resolved in runtime for key `\(key)`")
        }
        let signature = target.method(for: selector)

        typealias setValueForControlStateIMP = @convention(c) (AnyObject, Selector, AnyObject, UIControl.State) -> Void
        let method = unsafeBitCast(signature, to: setValueForControlStateIMP.self)
        method(target, selector, resolvedValue as AnyObject, parseState(from: attributeName).resolveUnion())
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

    private func parseState(from attributeName: String) -> [ControlState] {
        return attributeName.components(separatedBy: ".").dropFirst(namespace.count + 1).compactMap(ControlState.init)
    }
}

