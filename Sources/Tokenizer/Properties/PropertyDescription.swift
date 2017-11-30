//
//  PropertyDescription.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if ReactantRuntime
import UIKit
#endif

public protocol PropertyDescription {
    var name: String { get }
    var namespace: [PropertyContainer.Namespace] { get }

    func materialize(attributeName: String, value: String) throws -> Property

    func matches(attributeName: String) -> Bool

//    func application(of property: Property, on target: String) -> String

    #if ReactantRuntime

//    func apply(_ property: Property, on object: AnyObject) throws -> Void
    #endif
}

public protocol TypedPropertyDescription: PropertyDescription {
    associatedtype ValueType: SupportedPropertyType
}

extension PropertyDescription {
    public func matches(attributeName: String) -> Bool {
        return attributeName == namespace.resolvedAttributeName(name: name)
    }
}
