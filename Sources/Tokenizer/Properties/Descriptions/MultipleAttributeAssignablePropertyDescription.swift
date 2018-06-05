//
//  MultipleAttributeAssignablePropertyDescription.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public struct MultipleAttributeAssignablePropertyDescription<T: MultipleAttributeSupportedPropertyType>: TypedPropertyDescription {
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
        var property: MultipleAttributeAssignableProperty<T>
        if let storedProperty = getProperty(from: properties) {
            property = storedProperty
        } else {
            property = MultipleAttributeAssignableProperty(namespace: namespace, name: name, description: self, value: value)
        }
        property.value = value
        setProperty(property, to: &properties)
    }

    private func getProperty(from dictionary: [String: Property]) -> MultipleAttributeAssignableProperty<T>? {
        return dictionary[dictionaryKey()] as? MultipleAttributeAssignableProperty<T>
    }

    private func setProperty(_ property: Property, to dictionary: inout [String: Property]) {
        dictionary[dictionaryKey()] = property
    }

    private func dictionaryKey() -> String {
        return namespace.resolvedAttributeName(name: name)
    }
}

extension MultipleAttributeAssignablePropertyDescription: MultipleAttributePropertyDescription where T: MultipleAttributeSupportedPropertyType {

    public func materialize(attributes: [String : String]) throws -> Property {
        let namePrefixLength = namespace.resolvedAttributeName(name: name).count

        let nameAdjustedAttributes = Dictionary(attributes.map { item -> (String, String) in
            var mutableKey = item.key
            mutableKey.removeFirst(namePrefixLength)
            return (mutableKey, item.value)
        }, uniquingKeysWith: { $1 })

        let materializedValue = try T.materialize(from: nameAdjustedAttributes)

        return MultipleAttributeAssignableProperty(namespace: namespace, name: name, description: self, value: materializedValue)
    }
}

