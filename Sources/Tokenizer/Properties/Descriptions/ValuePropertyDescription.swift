//
//  ValuePropertyDescription.swift
//  ReactantUI
//
//  Created by Matous Hybl on 05/09/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/**
 * Property description describing a property using a single XML attribute.
 */
public struct ValuePropertyDescription<T: AttributeSupportedPropertyType>: TypedPropertyDescription {
    public typealias ValueType = T

    public let namespace: [PropertyContainer.Namespace]
    public let name: String

    /**
     * Get a property using the dictionary passed.
     * - parameter properties: **[name: property]** dictionary to search in
     * - returns: found property's value if found, nil otherwise
     */
    public func get(from properties: [String: Property]) -> T? {
        let property = getProperty(from: properties)
        return property?.value
    }

    /**
     * Set a property's value from the dictionary passed.
     * A new property is created if no property is found.
     * - parameter value: value to be set to the property
     * - parameter properties: **[name: property]** dictionary to search in
     */
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

    /**
     * Gets a property from the **[name: property]** dictionary passed or nil.
     * - parameter dictionary: properties dictionary
     * - returns: found property or nil
     */
    private func getProperty(from dictionary: [String: Property]) -> ValueProperty<T>? {
        return dictionary[dictionaryKey()] as? ValueProperty<T>
    }

    /**
     * Inserts the property passed into the dictionary of properties.
     * - parameter property: property to insert
     * - parameter dictionary: **[name: property]** dictionary to insert into
     */
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

