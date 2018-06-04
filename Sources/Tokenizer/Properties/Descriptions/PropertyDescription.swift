//
//  PropertyDescription.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//
import Foundation

#if ReactantRuntime
import UIKit
#endif

public protocol PropertyDescription {
    var name: String { get }
    var namespace: [PropertyContainer.Namespace] { get }
    var type: AttributeSupportedPropertyType.Type { get }
}

public protocol AttributePropertyDescription: PropertyDescription {
    func materialize(attributeName: String, value: String) throws -> Property

    func matches(attributeName: String) -> Bool
}

public protocol ElementPropertyDescription: PropertyDescription {
    func materialize(element: XMLElement) throws -> Property

    func matches(element: XMLElement) -> Bool
}

public protocol TypedPropertyDescription: PropertyDescription {
    associatedtype ValueType: AttributeSupportedPropertyType
}

extension TypedPropertyDescription {
    public var type: AttributeSupportedPropertyType.Type {
        return ValueType.self
    }
}

extension AttributePropertyDescription {
    public func matches(attributeName: String) -> Bool {
        return attributeName == namespace.resolvedAttributeName(name: name)
    }
}

extension ElementPropertyDescription {
    public func matches(element: XMLElement) -> Bool {
        // FIXME Probably not correct
        return element.name == namespace.resolvedAttributeName(name: name)
    }
}
