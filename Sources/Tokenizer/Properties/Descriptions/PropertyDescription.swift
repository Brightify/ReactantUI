//
//  PropertyDescription.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/**
 * The base protocol for all the other `*PropertyDescription`s.
 */
public protocol PropertyDescription {
    var name: String { get }
    var namespace: [PropertyContainer.Namespace] { get }
    var type: SupportedPropertyType.Type { get }
}

/**
 * Used as a prototype for `Property` to be deserialized (i.e. materialized) from a single XML attribute given its name and value.
 * The `matches(attributeName:)` method has default implementation.
 */
public protocol AttributePropertyDescription: PropertyDescription {
    /**
     * Tries to create a `Property` using the passed attribute name and value.
     * - parameter attributeName: XML attribute name to check when materializing the property
     * - parameter value: attribute's right hand side, the value to use
     * - parameter condition: condition that encloses this property
     * - returns: if not thrown, materialized `Property`
     */
    func materialize(attributeName: String, value: String, condition: Condition?) throws -> Property

    /**
     * Checks whether the property description can handle the passed attributeName.
     * - parameter attributeName: attributeName to use when checking
     * - returns: whether the property description can handle the attributeName
     */
    func matches(attributeName: String) -> Bool
}

/**
 * Used as a prototype for `Property` to be deserialized (i.e. materialized) from a dictionary **[attributeName: value]**.
 * The `matches(attributeName:)` method has default implementation.
 */
public protocol MultipleAttributePropertyDescription: PropertyDescription {
    /**
     * Tries to create a `Property` using the passed **[attributeName: value]** dictionary.
     * - parameter attributes: dictionary where keys are XML attribute names and values are the right hand side values
     * - returns: if not thrown, materialized `Property`
     */
    func materialize(attributes: [String: String]) throws -> Property

    /**
     * Checks whether the property description can handle the passed attributeName.
     * - parameter attributeName: attributeName to use when checking
     * - returns: whether the property description can handle the attributeName
     */
    func matches(attributeName: String) -> Bool
}

/**
 * Used as a prototype for `Property` to be deserialized (i.e. materialized) from a single XML element.
 * The `matches(element:)` method has default implementation.
 */
public protocol ElementPropertyDescription: PropertyDescription {
    /**
     * Tries to create a `Property` using the passed XML element.
     * - parameter element: XML element used when materializing the `Property`
     * - returns: if not thrown, materialized `Property`
     */
    func materialize(element: XMLElement) throws -> Property

    /**
     * Checks whether the property description can handle the passed XML element.
     * - parameter element: XML element to use when checking
     * - returns: whether the property description can handle the XML element
     */
    func matches(element: XMLElement) -> Bool
}

public protocol TypedPropertyDescription: PropertyDescription {
    associatedtype ValueType: SupportedPropertyType
}

// MARK:- Default implementations.
extension TypedPropertyDescription {
    public var type: SupportedPropertyType.Type {
        return ValueType.self
    }
}

extension AttributePropertyDescription {
    public func matches(attributeName: String) -> Bool {
        return attributeName == namespace.resolvedAttributeName(name: name)
    }
}

extension MultipleAttributePropertyDescription {
    public func matches(attributeName: String) -> Bool {
        return attributeName.starts(with: namespace.resolvedAttributeName(name: name) + ".")
    }
}

extension ElementPropertyDescription {
    public func matches(element: XMLElement) -> Bool {
        // FIXME Probably not correct
        return element.name == namespace.resolvedAttributeName(name: name)
    }
}
