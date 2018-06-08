//
//  ElementControlStatePropertyDescription.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public struct ElementControlStatePropertyDescription<T: ElementSupportedPropertyType>: TypedPropertyDescription, ControlStatePropertyDescriptionMarker {
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
        var property: ElementControlStateProperty<T>
        if let storedProperty = getProperty(from: properties, for: state) {
            property = storedProperty
        } else {
            property = ElementControlStateProperty(namespace: namespace, name: name, state: state, description: self, value: value)
        }
        property.value = value
        setProperty(property, to: &properties, for: state)
    }

    private func getProperty(from dictionary: [String: Property], for state: [ControlState]) -> ElementControlStateProperty<T>? {
        return dictionary[dictionaryKey(for: state)] as? ElementControlStateProperty<T>
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
        return attributeName.components(separatedBy: "|").dropFirst(namespace.count + 1).compactMap(ControlState.init)
    }
}

extension ElementControlStatePropertyDescription: ElementPropertyDescription where T: ElementSupportedPropertyType {
    public func materialize(element: XMLElement) throws -> Property {
        let controlState: [ControlState]
        if let stateString = element.value(ofAttribute: "state") as String? {
            controlState = parseState(from: stateString)
        } else {
            controlState = [ControlState.normal]
        }

        let materializedValue = try T.materialize(from: element)
        return ElementControlStateProperty(namespace: namespace, name: name, state: controlState, description: self, value: materializedValue)
    }
}
