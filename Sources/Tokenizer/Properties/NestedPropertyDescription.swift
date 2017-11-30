//
//  NestedPropertyDescription.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if ReactantRuntime
import UIKit
#endif

//public func nestedAssignment<T: SupportedPropertyType>(name: String, field: String, namespace: String? = nil, optional: Bool = false, type: T.Type) -> NestedPropertyDescription<AssignablePropertyDescription<T>> {
//    return nestedAssignment(name: name, field: field, namespace: namespace, optional: optional, key: name, type: type)
//}
//
//public func nestedAssignment<T: SupportedPropertyType>(name: String, field: String, namespace: String? = nil, optional: Bool = false, key: String, type: T.Type) -> NestedPropertyDescription<AssignablePropertyDescription<T>> {
//    return nested(field: field, namespace: namespace, optional: optional,
//        property: assignable(name: name, key: key, type: type))
//}
//
//public func nested<PROPERTY: PropertyDescription>(field: String, namespace: String? = nil, optional: Bool = false, property: PROPERTY) -> NestedPropertyDescription<PROPERTY> {
//    return NestedPropertyDescription<PROPERTY>(field: field, namespace: namespace, optional: optional, nestedDescription: property)
//}

//extension PropertyDescription {
//    public func typeErased() -> AnyPropertyDescription {
//        return AnyPropertyDescription(of: self)
//    }
//}

//public struct AnyPropertyDescription: PropertyDescription {
//    public var name: String {
//        return _name()
//    }
//
//    private let _name: () -> String
//    private let _materialize: (_ attributeName: String, _ value: String) throws -> Property
//    private let _matches: (_ attributeName: String) -> Bool
//
//    init(of description: PropertyDescription) {
//        _name = { description.name }
//        _materialize = description.materialize
//        _matches = description.matches
//    }
//
//    public func materialize(attributeName: String, value: String) throws -> Property {
//        return try _materialize(attributeName, value)
//    }
//
//    public func matches(attributeName: String) -> Bool {
//        return _matches(attributeName)
//    }
//}
//
//#if swift(>=3.1)
//public func nested(field: String, namespace: String? = nil, optional: Bool = false, properties: [PropertyDescription]) -> [PropertyDescription] {
//    return properties.map {
//        nested(field: field, namespace: namespace, optional: optional, property: $0.typeErased())
//    }
//}
//#else
//public func nested<T: SupportedPropertyType>(field: String, namespace: String? = nil, optional: Bool = false, properties: [PropertyDescription]) -> [PropertyDescription] {
//    return properties.map {
//        nested(field: field, namespace: namespace, optional: optional, property: $0)
//    }
//}
//#endif
//
//public struct NestedProperty<PROPERTY: Property, DESCRIPTION: PropertyDescription>: Property {
//    public let attributeName: String
//    public let description: NestedPropertyDescription<DESCRIPTION>
//    public var nestedProperty: PROPERTY
//
//    public func application(on target: String) -> String {
//        return nestedProperty.application(on: "\(target).\(description.field)\(description.optional ? "?" : "")")
//    }
//    
//    #if SanAndreas
//    public func dematerialize() -> MagicAttribute {
//        return nestedProperty.dematerialize()//MagicAttribute(name: nestedProperty.attributeName, value: nestedProperty.dematerialize())
//    }
//    #endif
//
//    #if ReactantRuntime
//    public func apply(on object: AnyObject) throws {
//        guard let innerObject = object.value(forKeyPath: description.field) as AnyObject? else {
//            // FIXME We should throw here if `optional` is `false`
//            return
//        }
//        try nestedProperty.apply(on: innerObject)
//    }
//    #endif
//}
//
//public struct NestedPropertyDescription<PROPERTY: PropertyDescription>: PropertyDescription {
//    public let field: String
//    public let namespace: String?
//    public let optional: Bool
//    public let nestedDescription: PROPERTY
//
//    public var name: String {
//        if let namespace = namespace {
//            return "\(namespace).\(nestedDescription.name)"
//        } else {
//            return nestedDescription.name
//        }
//    }
//
//
//    public func materialize(attributeName: String, value: String) throws -> Property {
//        if let namespace = namespace {
//            return try nestedDescription.materialize(attributeName: "\(namespace).\(attributeName)", value: value)
//        } else {
//            return try nestedDescription.materialize(attributeName: attributeName, value: value)
//        }
//    }
//
//    public func isSet(in properties: [String: Property]) -> Bool {
//        guard let property = getProperty(from: properties) else { return false }
//        return property.value is T
//    }
//
//    public func get(from properties: [String: Property]) -> T? {
//        let property = getProperty(from: properties)
//        return property?.value as? T
//    }
//
//    public func set(value: T, to properties: inout [String: Property]) {
//        var property = getProperty(from: properties) ?? makeProperty(with: name, value: value)
//        property.value = value
//        setProperty(property, to: &properties)
//    }
//
//    private func getProperty(from dictionary: [String: Property]) -> Property? {
//        return dictionary[name]
//    }
//
//    private func setProperty(_ property: Property, to dictionary: inout [String: Property]) {
//        dictionary[name] = property
//    }

//    private func makeProperty(with attributeName: String, value: T) -> Property {
//        return AssignableProperty(attributeName: attributeName, description: self, value: value)
//    }
//}
