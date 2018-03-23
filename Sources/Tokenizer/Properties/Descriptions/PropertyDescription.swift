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
    var type: SupportedPropertyType.Type { get }

    func materialize(attributeName: String, value: String) throws -> Property

    func matches(attributeName: String) -> Bool
}

public protocol TypedPropertyDescription: PropertyDescription {
    associatedtype ValueType: SupportedPropertyType
}

extension TypedPropertyDescription {
    public var type: SupportedPropertyType.Type {
        return ValueType.self
    }
}

extension PropertyDescription {
    public func matches(attributeName: String) -> Bool {
        return attributeName == namespace.resolvedAttributeName(name: name)
    }
}
