//
//  AssignablePropertyDescription.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if ReactantRuntime
import UIKit
#endif

//public func assignable<T: SupportedPropertyType>(name: String, type: T.Type) -> AssignablePropertyDescription<T> {
//    return assignable(name: name, key: name, type: type)
//}
//
//public func assignable<T: SupportedPropertyType>(name: String, key: String, type: T.Type) -> AssignablePropertyDescription<T> {
//    return assignable(name: name, swiftName: name, key: key, type: type)
//}
//
//public func assignable<T: SupportedPropertyType>(name: String, swiftName: String, key: String, type: T.Type) -> AssignablePropertyDescription<T> {
//    return AssignablePropertyDescription(name: name, swiftName: swiftName, key: key)
//}

public struct AssignableProperty<T: SupportedPropertyType>: TypedProperty {
    public let namespace: [PropertyContainer.Namespace]
    public let name: String
    public let description: AssignablePropertyDescription<T>
    public var value: T
    
    public var attributeName: String {
        return namespace.resolvedAttributeName(name: name)
    }

    public func application(on target: String) -> String {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)
        return "\(namespacedTarget).\(description.swiftName) = \(value.generated)"
    }
    
    #if SanAndreas
    public func dematerialize() -> MagicAttribute {
        return MagicAttribute(name: attributeName, value: value.dematerialize())
    }
    #endif

    #if ReactantRuntime
    public func apply(on object: AnyObject) throws {
        let key = description.key
        guard let resolvedValue = value.runtimeValue else {
            throw LiveUIError(message: "!! Value `\(value)` couldn't be resolved in runtime for key `\(key)`")
        }

        let target = try resolveTarget(for: object)
    
        guard target.responds(to: Selector("set\(key.capitalizingFirstLetter()):")) else {
            throw LiveUIError(message: "!! Object `\(target)` doesn't respond to selector `\(key)` to set value `\(value)`")
        }
        var mutableObject: AnyObject? = resolvedValue as AnyObject
        do {
            //            try object.validateValue(&mutableObject, forKey: key)
            target.setValue(mutableObject, forKey: key)
        } catch {
            throw LiveUIError(message: "!! Value `\(value)` isn't valid for key `\(key)` on object `\(target)")
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

public struct AssignablePropertyDescription<T: SupportedPropertyType>: TypedPropertyDescription {
    public typealias ValueType = T
    
    public let namespace: [PropertyContainer.Namespace]
    public let name: String
    public let swiftName: String
    public let key: String

    public func get(from properties: [String: Property]) -> T? {
        let property = getProperty(from: properties)
        return property?.value
    }

    public func set(value: T, to properties: inout [String: Property]) {
        var property: AssignableProperty<T>
        if let storedProperty = getProperty(from: properties) {
            property = storedProperty
        } else {
            property = AssignableProperty(namespace: namespace, name: name, description: self, value: value)
        }
        property.value = value
        setProperty(property, to: &properties)
    }

    public func materialize(attributeName: String, value: String) throws -> Property {
        let materializedValue = try T.materialize(from: value)
        let keyPath = namespace.resolvedKeyPath + "."
        
        return AssignableProperty(namespace: namespace, name: name, description: self, value: materializedValue)
    }

    private func getProperty(from dictionary: [String: Property]) -> AssignableProperty<T>? {
        return dictionary[dictionaryKey()] as? AssignableProperty<T>
    }

    private func setProperty(_ property: Property, to dictionary: inout [String: Property]) {
        dictionary[dictionaryKey()] = property
    }
    
    private func dictionaryKey() -> String {
        return namespace.resolvedAttributeName(name: name)
    }

//    func application(of property: Property, on target: String) -> String {
//        return "\(target).\(swiftName) = \(property.value.generated)"
//    }
//
//    #if ReactantRuntime
//    func apply(_ property: Property, on object: AnyObject) throws {
//        guard let resolvedValue = property.value.value else {
//            throw LiveUIError(message: "!! Value `\(property.value)` couldn't be resolved in runtime for key `\(key)`")
//        }
//
//        guard object.responds(to: Selector("set\(key.capitalizingFirstLetter()):")) else {
//            throw LiveUIError(message: "!! Object `\(object)` doesn't respond to selector `\(key)` to set value `\(property.value)`")
//        }
//        var mutableObject: AnyObject? = resolvedValue as AnyObject
//        do {
////            try object.validateValue(&mutableObject, forKey: key)
//            object.setValue(mutableObject, forKey: key)
//        } catch {
//            throw LiveUIError(message: "!! Value `\(property.value)` isn't valid for key `\(key)` on object `\(object)")
//        }
//    }
//    #endif
}
