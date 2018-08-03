//
//  MultipleAttributeAssignablePropertyDescription.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/**
 * Property description describing a property using multiple XML attributes.
 */
public struct MultipleAttributeAssignablePropertyDescription<T: MultipleAttributeSupportedPropertyType>: TypedPropertyDescription {
    public typealias ValueType = T

    public let namespace: [PropertyContainer.Namespace]
    public let name: String
    public let swiftName: String
    public let key: String

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
        var property: MultipleAttributeAssignableProperty<T>
        if let storedProperty = getProperty(from: properties) {
            property = storedProperty
        } else {
            property = MultipleAttributeAssignableProperty(namespace: namespace, name: name, description: self, value: value)
        }
        property.value = value
        setProperty(property, to: &properties)
    }

    /**
     * Gets a property from the **[name: property]** dictionary passed or nil.
     * - parameter dictionary: properties dictionary
     * - returns: found property or nil
     */
    private func getProperty(from dictionary: [String: Property]) -> MultipleAttributeAssignableProperty<T>? {
        return dictionary[dictionaryKey()] as? MultipleAttributeAssignableProperty<T>
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

extension MultipleAttributeAssignablePropertyDescription: MultipleAttributePropertyDescription where T: MultipleAttributeSupportedPropertyType {
    public func materialize(attributes: [String : String]) throws -> Property {
        let namePrefixLength = namespace.resolvedAttributeName(name: name).count + 1

        let nameAdjustedAttributes = Dictionary(attributes.map { item -> (String, String) in
            var mutableKey = item.key
            mutableKey.removeFirst(namePrefixLength)
            return (mutableKey, item.value)
        }, uniquingKeysWith: { $1 })

        let materializedValue = try T.materialize(from: nameAdjustedAttributes)

        return MultipleAttributeAssignableProperty(namespace: namespace, name: name, description: self, value: materializedValue)
    }
}

