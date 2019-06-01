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

/**
 * Base protocol for UI element properties.
 */
public protocol Property {
    var name: String { get set }
    
    var attributeName: String { get }
    
    var namespace: [PropertyContainer.Namespace] { get set }

    var anyValue: AnyPropertyValue { get }

    var anyDescription: PropertyDescription { get }

    func application(context: PropertyContext) -> String

    func application(on target: String, context: PropertyContext) -> String

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


    public var requiresTheme: Bool {
        switch self {
        case .value(let value):
            return value.requiresTheme
        case .state:
            return false
        }
    }

    public func generate(context: SupportedPropertyTypeContext) -> String {
        return typeErased().generate(context: context)
    }

    public func typeErased() -> AnyPropertyValue {
        switch self {
        case .value(let value):
            return .value(value)
        case .state(let name):
            return .state(name, T.self)
        }
    }
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

    public func generate(context: SupportedPropertyTypeContext) -> String {
        switch self {
        case .value(let value):
            return value.generate(context: context)
        case .state(let name, _):
            return name
        }
    }
}
