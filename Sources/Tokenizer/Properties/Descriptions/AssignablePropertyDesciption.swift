//
//  AssignablePropertyDesciption.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

// TODO: supportedcosi?
public struct AssignablePropertyDescription<T: AttributeSupportedPropertyType>: TypedPropertyDescription {
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

    private func getProperty(from dictionary: [String: Property]) -> AssignableProperty<T>? {
        return dictionary[dictionaryKey()] as? AssignableProperty<T>
    }

    private func setProperty(_ property: Property, to dictionary: inout [String: Property]) {
        dictionary[dictionaryKey()] = property
    }

    private func dictionaryKey() -> String {
        return namespace.resolvedAttributeName(name: name)
    }
}

extension AssignablePropertyDescription: AttributePropertyDescription where T: AttributeSupportedPropertyType {

    public func materialize(attributeName: String, value: String) throws -> Property {
        let materializedValue = try T.materialize(from: value)

        return AssignableProperty(namespace: namespace, name: name, description: self, value: materializedValue)
    }
}
