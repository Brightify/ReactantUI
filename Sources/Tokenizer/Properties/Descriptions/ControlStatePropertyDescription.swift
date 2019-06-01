//
//  ControlStatePropertyDescription.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/**
 * Used to mark ALL control state property descriptions.
 * This is necessary for correct XSD generation.
 */
public protocol ControlStatePropertyDescriptionMarker { }

/**
 * Property description describing a property with a control state using a single XML attribute.
 */
public struct ControlStatePropertyDescription<T: AttributeSupportedPropertyType>: TypedPropertyDescription, ControlStatePropertyDescriptionMarker {
    public typealias ValueType = T

    public let namespace: [PropertyContainer.Namespace]
    public let name: String
    public let key: String
    public let defaultValue: T

    /**
     * Checks whether the passed attribute name can be handled by this `PropertyDescription`.
     * - parameter attributeName: attribute name to be checked
     * - returns: whether or not the passed attribute name can be handled
     */
    public func matches(attributeName: String) -> Bool {
        let resolvedAttributeName = namespace.resolvedAttributeName(name: name)
        return attributeName == resolvedAttributeName || attributeName.hasPrefix("\(resolvedAttributeName).")
    }

    /**
     * Get a property using the dictionary passed for the passed control state.
     * - parameter properties: **[name: property]** dictionary to search in
     * - parameter state: `[ControlState]` to use when getting a property in the dictionary
     * - returns: found property's value if found for the passed control state, nil otherwise
     */
    public func get(from properties: [String: Property], for state: [ControlState]) -> PropertyValue<T>? {
        let property = getProperty(from: properties, for: state)
        return property?.value
    }

    /**
     * Set a property's value from the dictionary passed for the passed control state.
     * A new property is created if no property corresponding to the control state is found.
     * - parameter value: value to be set to the property
     * - parameter properties: **[name: property]** dictionary to search in
     * - parameter state: `[ControlState]` to find within the dictionary
     */
    public func set(value: PropertyValue<T>, to properties: inout [String: Property], for state: [ControlState]) {
        var property: ControlStateProperty<T>
        if let storedProperty = getProperty(from: properties, for: state) {
            property = storedProperty
        } else {
            property = ControlStateProperty(namespace: namespace, name: name, state: state, description: self, value: value)
        }
        property.value = value
        setProperty(property, to: &properties, for: state)
    }

    /**
     * Gets a property from the **[name: property]** dictionary passed for the passed state or nil.
     * - parameter dictionary: properties dictionary
     * - parameter state: `[ControlState]` for which to search
     * - returns: found property or nil
     */
    public func getProperty(from dictionary: [String: Property], for state: [ControlState]) -> ControlStateProperty<T>? {
        return dictionary[dictionaryKey(for: state)] as? ControlStateProperty<T>
    }

    /**
     * Inserts the property passed into the dictionary of properties for passed state.
     * - parameter property: property to insert
     * - parameter dictionary: **[name: property]** dictionary to insert into
     * - parameter state: `[ControlState]` to insert with
     */
    public func setProperty(_ property: Property, to dictionary: inout [String: Property], for state: [ControlState]) {
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

extension ControlStatePropertyDescription: AttributePropertyDescription where T: AttributeSupportedPropertyType {
    public func materialize(attributeName: String, value: String) throws -> Property {
        let materializedValue: PropertyValue<T>
        if value.starts(with: "$") {
            materializedValue = .state(String(value.dropFirst()))
        } else {
            materializedValue = .value(try T.materialize(from: value))
        }
        return ControlStateProperty(namespace: namespace, name: name, state: parseState(from: attributeName), description: self, value: materializedValue)
    }
}
