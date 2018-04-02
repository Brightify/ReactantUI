//
//  ControlStatePropertyDescription.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public protocol ControlStatePropertyDescriptionMarker { }

public struct ControlStatePropertyDescription<T: SupportedPropertyType>: TypedPropertyDescription, ControlStatePropertyDescriptionMarker {
    public typealias ValueType = T

    public let namespace: [PropertyContainer.Namespace]
    public let name: String
    public let key: String

    public func matches(attributeName: String) -> Bool {
        let resolvedAttributeName = namespace.resolvedAttributeName(name: name)
        return attributeName == resolvedAttributeName || attributeName.hasPrefix("\(resolvedAttributeName).")
    }

    public func get(from properties: [String: Property], for state: [ControlState]) -> T? {
        let property = getProperty(from: properties, for: state)
        return property?.value
    }

    public func set(value: T, to properties: inout [String: Property], for state: [ControlState]) {
        var property: ControlStateProperty<T>
        if let storedProperty = getProperty(from: properties, for: state) {
            property = storedProperty
        } else {
            property = ControlStateProperty(namespace: namespace, name: name, state: state, description: self, value: value)
        }
        property.value = value
        setProperty(property, to: &properties, for: state)
    }

    public func materialize(attributeName: String, value: String) throws -> Property {
        let materializedValue = try T.materialize(from: value)
        return ControlStateProperty(namespace: namespace, name: name, state: parseState(from: attributeName), description: self, value: materializedValue)
    }

    private func getProperty(from dictionary: [String: Property], for state: [ControlState]) -> ControlStateProperty<T>? {
        return dictionary[dictionaryKey(for: state)] as? ControlStateProperty<T>
    }

    private func setProperty(_ property: Property, to dictionary: inout [String: Property], for state: [ControlState]) {
        dictionary[dictionaryKey(for: state)] = property
    }

    private func dictionaryKey(for state: [ControlState]) -> String {
        if state == [.normal] || state == [] {
            return namespace.resolvedAttributeName(name: "\(name)")
        } else {
            return namespace.resolvedAttributeName(name: "\(name).\(state.name)")
        }
    }

    private func parseState(from attributeName: String) -> [ControlState] {
        return attributeName.components(separatedBy: ".").dropFirst(namespace.count + 1).compactMap(ControlState.init)
    }
}
