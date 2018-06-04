//
//  ElementAssignablePropertyDescription.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 04/06/2018.
//

import Foundation

public struct ElementAssignablePropertyDescription<T: ElementSupportedPropertyType>: TypedPropertyDescription {
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
        var property: ElementAssignableProperty<T>
        if let storedProperty = getProperty(from: properties) {
            property = storedProperty
        } else {
            property = ElementAssignableProperty(namespace: namespace, name: name, description: self, value: value)
        }
        property.value = value
        setProperty(property, to: &properties)
    }

    private func getProperty(from dictionary: [String: Property]) -> ElementAssignableProperty<T>? {
        return dictionary[dictionaryKey()] as? ElementAssignableProperty<T>
    }

    private func setProperty(_ property: Property, to dictionary: inout [String: Property]) {
        dictionary[dictionaryKey()] = property
    }

    private func dictionaryKey() -> String {
        return namespace.resolvedAttributeName(name: name)
    }
}

extension ElementAssignablePropertyDescription: ElementPropertyDescription {

    public func materialize(element: XMLElement) throws -> Property {
        let materializedValue = try T.materialize(from: element)

        return ElementAssignableProperty(namespace: namespace, name: name, description: self, value: materializedValue)
    }
}
