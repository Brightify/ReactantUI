//
//  AssignablePropertyDescription.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/**
 * Standard typed property obtained from an XML attribute.
 */
public struct AssignableProperty<T: AttributeSupportedPropertyType>: TypedProperty {
    public var namespace: [PropertyContainer.Namespace]
    public var name: String
    public var description: AssignablePropertyDescription<T>
    public var value: T
    public var condition: Condition?
    
    public var attributeName: String {
        return namespace.resolvedAttributeName(name: name)
    }

    /**
     * - parameter target: UI element to be targetted with the property
     * - parameter context: property context to use
     * - returns: Swift `String` representation of the property application on the target
     */
    public func application(on target: String, context: PropertyContext) -> String {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)
        if let condition = condition {
            return """
            if \(condition.generateSwift(viewName: namespacedTarget)) {
                \(namespacedTarget).\(description.swiftName) = \(value.generate(context: context.child(for: value)))
            }
            """
        } else {
            return "\(namespacedTarget).\(description.swiftName) = \(value.generate(context: context.child(for: value)))"
        }
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
        let selector = Selector("set\(key.capitalizingFirstLetter()):")

        let target = try resolveTarget(for: object)

        guard target.responds(to: selector) else {
            throw LiveUIError(message: "!! Object `\(target)` doesn't respond to selector `\(key)` to set value `\(value)`")
        }
        guard let resolvedValue = value.runtimeValue(context: context.child(for: value)) else {
            throw LiveUIError(message: "!! Value `\(value)` couldn't be resolved in runtime for key `\(key)`")
        }

        do {
            try catchException {
                _ = target.setValue(resolvedValue, forKey: key)
            }
        } catch {
            _ = target.perform(selector, with: resolvedValue)
        }

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
