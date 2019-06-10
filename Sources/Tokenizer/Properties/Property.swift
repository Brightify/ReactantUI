//
//  Property.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

/**
 * Base protocol for UI element properties.
 */
public protocol Property {
    var name: String { get set }
    
    var attributeName: String { get }
    
    var namespace: [PropertyContainer.Namespace] { get set }

    var anyValue: AnyPropertyValue { get }

    var anyDescription: PropertyDescription { get }

    #if canImport(SwiftCodeGen)
    func application(context: PropertyContext) -> Expression

    func application(on target: String, context: PropertyContext) -> Statement
    #endif

    #if SanAndreas
    func dematerialize(context: PropertyContext) -> XMLSerializableAttribute
    #endif
    
    #if canImport(UIKit)
    func apply(on object: AnyObject, context: PropertyContext) throws -> Void
    #endif
}

public protocol TypedProperty: Property {
    associatedtype ValueType
    associatedtype PropertyDescriptionType: TypedPropertyDescription where PropertyDescriptionType.ValueType == ValueType

    var value: PropertyValue<ValueType> { get set }

    var description: PropertyDescriptionType { get }
}

extension Property where Self: TypedProperty {
    public var anyValue: AnyPropertyValue {
        return value.typeErased()
    }

    public var anyDescription: PropertyDescription {
        return description
    }
}

public enum PropertyValue<T: SupportedPropertyType> {
    case value(T)
    case state(String)

    public var value: T? {
        switch self {
        case .value(let value):
            return value
        case .state:
            return nil
        }
    }

    public var requiresTheme: Bool {
        switch self {
        case .value(let value):
            return value.requiresTheme
        case .state:
            return false
        }
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return typeErased().generate(context: context)
    }
    #endif

    public func typeErased() -> AnyPropertyValue {
        switch self {
        case .value(let value):
            return .value(value)
        case .state(let name):
            return .state(name, T.self)
        }
    }

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) throws -> Any? {
        switch self {
        case .value(let value):
            return try value.runtimeValue(context: context.child(for: value))
        case .state(let name):
            return try context.resolveStateProperty(named: name)
        }
    }
    #endif
}


public enum AnyPropertyValue {
    case value(SupportedPropertyType)
    case state(String, SupportedPropertyType.Type)

    public var requiresTheme: Bool {
        switch self {
        case .value(let value):
            return value.requiresTheme
        case .state:
            return false
        }
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        switch self {
        case .value(let value):
            return value.generate(context: context)
        case .state(let name, _):
            return .constant(name)
        }
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) throws -> Any? {
        switch self {
        case .value(let value):
            return try value.runtimeValue(context: context.child(for: value))
        case .state(let name, _):
            return try context.resolveStateProperty(named: name)
        }
    }
    #endif
}
