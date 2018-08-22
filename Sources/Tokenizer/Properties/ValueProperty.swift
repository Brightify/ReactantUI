//
//  ValueProperty.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

#if canImport(UIKit)
import UIKit
#endif

/**
 * Typed property obtained from an XML attribute.
 * The most basic typed property. Just sets the property using the parsed value.
 */
public struct ValueProperty<T: AttributeSupportedPropertyType>: TypedProperty {
    public var namespace: [PropertyContainer.Namespace]
    public var name: String
    public var description: ValuePropertyDescription<T>
    public var value: T
    public let condition: Condition? = nil

    public var attributeName: String {
        return namespace.resolvedAttributeName(name: name)
    }

    public func application(on target: String, context: PropertyContext) -> String {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)
        let applicationString = "\(namespacedTarget).\(description.name) = \(value.generate(context: context.child(for: value)))"
        return condition.generateSwiftEnclosingIfPresent(viewName: namespacedTarget, applicationString)
    }

    #if SanAndreas
    public func dematerialize(context: PropertyContext) -> XMLSerializableAttribute {
        // TODO: conditions
        return XMLSerializableAttribute(name: attributeName, value: value.dematerialize(context: context.child(for: value)))
    }
    #endif

    #if canImport(UIKit)
    public func apply(on object: AnyObject, context: PropertyContext) throws {

    }
    #endif
}
