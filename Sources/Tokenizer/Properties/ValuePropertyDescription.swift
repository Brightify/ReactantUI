//
//  ValuePropertyDescription.swift
//  ReactantUI
//
//  Created by Matous Hybl on 05/09/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if ReactantRuntime
    import UIKit
#endif

public struct ValueProperty<T: SupportedPropertyType>: TypedProperty {
    public let namespace: [PropertyContainer.Namespace]
    public let name: String
    public let description: ValuePropertyDescription<T>
    public var value: T

    public var attributeName: String {
        return namespace.resolvedAttributeName(name: name)
    }

    public func application(on target: String) -> String {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)
        return "\(namespacedTarget).\(description.name) = \(value.generated)"
    }

    #if SanAndreas
    public func dematerialize() -> MagicAttribute {
        return MagicAttribute(name: attributeName, value: value.dematerialize())
    }
    #endif

    #if ReactantRuntime
    public func apply(on object: AnyObject) throws {

    }
    #endif
}

public struct ValuePropertyDescription<T: SupportedPropertyType>: TypedPropertyDescription {
    public typealias ValueType = T

    public let namespace: [PropertyContainer.Namespace]
    public let name: String

    public func get(from properties: [String: Property]) -> T? {
        let property = getProperty(from: properties)
        return property?.value
    }

    public func set(value: T, to properties: inout [String: Property]) {
        var property: ValueProperty<T>
        if let storedProperty = getProperty(from: properties) {
            property = storedProperty
        } else {
            property = ValueProperty(namespace: namespace, name: name, description: self, value: value)
        }
        property.value = value
        setProperty(property, to: &properties)
    }

    public func materialize(attributeName: String, value: String) throws -> Property {
        let materializedValue = try T.materialize(from: value)
        let keyPath = namespace.resolvedKeyPath + "."

        return ValueProperty(namespace: namespace, name: name, description: self, value: materializedValue)
    }

    private func getProperty(from dictionary: [String: Property]) -> ValueProperty<T>? {
        return dictionary[dictionaryKey()] as? ValueProperty<T>
    }

    private func setProperty(_ property: Property, to dictionary: inout [String: Property]) {
        dictionary[dictionaryKey()] = property
    }

    private func dictionaryKey() -> String {
        return namespace.resolvedAttributeName(name: name)
    }
}

