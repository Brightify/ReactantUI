//
//  ValueProperty.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

/**
 * Typed property obtained from an XML attribute.
 * The most basic typed property. Just sets the property using the parsed value.
 */
public struct ValueProperty<T: AttributeSupportedPropertyType>: TypedProperty {
    public var namespace: [PropertyContainer.Namespace]
    public var name: String
    public var description: ValuePropertyDescription<T>
    public var value: PropertyValue<T>

    public var attributeName: String {
        return namespace.resolvedAttributeName(name: name)
    }

    #if canImport(SwiftCodeGen)
    public func application(context: PropertyContext) -> Expression {
        return value.generate(context: context.child(for: value))
    }

    public func application(on target: String, context: PropertyContext) -> Statement {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)
        return .assignment(target: .constant("\(namespacedTarget).\(description.name)"), expression: application(context: context))
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: PropertyContext) -> XMLSerializableAttribute {
        return XMLSerializableAttribute(name: attributeName, value: value.dematerialize(context: context.child(for: value)))
    }
    #endif

    #if canImport(UIKit)
    public func apply(on object: AnyObject, context: PropertyContext) throws {

    }
    #endif
}
