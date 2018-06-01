//
//  ValueProperty.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

#if ReactantRuntime
import UIKit
#endif

public struct ValueProperty<T: AttributeSupportedPropertyType>: TypedProperty {
    public let namespace: [PropertyContainer.Namespace]
    public let name: String
    public let description: ValuePropertyDescription<T>
    public var value: T

    public var attributeName: String {
        return namespace.resolvedAttributeName(name: name)
    }

    public func application(on target: String, context: PropertyContext) -> String {
        let namespacedTarget = namespace.resolvedSwiftName(target: target)
        return "\(namespacedTarget).\(description.name) = \(value.generated)"
    }

    #if SanAndreas
    public func dematerialize(context: PropertyContext) -> XMLSerializableAttribute {
        return XMLSerializableAttribute(name: attributeName, value: value.dematerialize())
    }
    #endif

    #if ReactantRuntime
    public func apply(on object: AnyObject, context: PropertyContext) throws {

    }
    #endif
}
