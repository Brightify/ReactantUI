//
//  ValuePropertyDescription.swift
//  ReactantUI
//
//  Created by Matous Hybl on 05/09/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public struct ValuePropertyDescription<T: AttributeSupportedPropertyType>: TypedPropertyDescription {
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

extension ValuePropertyDescription: AttributePropertyDescription /*where T: AttributeSupportedPropertyType*/ {
    public func materialize(attributeName: String, value: String) throws -> Property {
        let materializedValue = try T.materialize(from: value)

        return ValueProperty(namespace: namespace, name: name, description: self, value: materializedValue)
    }
}

