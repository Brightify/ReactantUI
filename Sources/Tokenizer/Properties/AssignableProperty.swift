//
//  AssignablePropertyDescription.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public struct AssignableProperty<T: SupportedPropertyType>: TypedProperty {
    public let namespace: [PropertyContainer.Namespace]
    public let name: String
    public let description: AssignablePropertyDescription<T>
    public var value: T
    
    public var attributeName: String {
        return namespace.resolvedAttributeName(name: name)
    }

    public func application(on target: String, context: ElementContext) -> String {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)
        return "\(namespacedTarget).\(description.swiftName) = \(value.generated)"
    }
    
    #if SanAndreas
    public func dematerialize(context: ElementContext) -> XMLSerializableAttribute {
        return XMLSerializableAttribute(name: attributeName, value: value.dematerialize())
    }
    #endif

    #if ReactantRuntime
    public func apply(on object: AnyObject, context: ElementContext) throws {
        let key = description.key
        let selector = Selector("set\(key.capitalizingFirstLetter()):")

        let target = try resolveTarget(for: object)

        guard target.responds(to: selector) else {
            throw LiveUIError(message: "!! Object `\(target)` doesn't respond to selector `\(key)` to set value `\(value)`")
        }
        guard let resolvedValue = value.runtimeValue else {
            throw LiveUIError(message: "!! Value `\(value)` couldn't be resolved in runtime for key `\(key)`")
        }

        do {
            try catchException {
                _ = target.setValue(resolvedValue, forKey: key)
            }
        } catch {
            target.perform(selector, with: resolvedValue)
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
