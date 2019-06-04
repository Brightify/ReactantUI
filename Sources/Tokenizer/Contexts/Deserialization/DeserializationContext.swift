//
//  TokenizationContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import Foundation

public protocol DeserializationContext {
}

public protocol HasElementIdProvider {
    var elementIdProvider: ElementIdProvider { get }
}

public protocol CanDeserializeUIElement {
    func deserialize(element: XMLElement) throws -> UIElement?
}

public protocol CanDeserializeStyleGroup {
    func deserialize(element: XMLElement) throws -> StyleGroup
}

public protocol CanDeserializeStyleElement {
    func deserialize(element: XMLElement, groupName: String?) throws -> Style
}

public protocol CanDeserializeDefinition {
    func deserialize(element: XMLElement, type: String) throws -> ComponentDefinition
}

public protocol HasUIElementFactoryRegistry {
    func factory(for elementName: String) -> UIElementFactory?
}

//extension CanDeserializeDefinition where Self: HasParentContext, Self.ParentContext: CanDeserializeDefinition {
//    public func deserialize(element: XMLElement) throws -> ComponentDefinition {
//        return try parentContext.deserialize(element: element)
//    }
//}
//
//extension HasParentContext where ParentContext: CanDeserializeDefinition {
//    public func deserialize(element: XMLElement) throws -> ComponentDefinition {
//        return try parentContext.deserialize(element: element)
//    }
//}

//
//extension HasUIElementFactoryRegistry where Self: HasParentContext, Self.ParentContext: HasUIElementFactoryRegistry {
//    public func factory(for elementName: String) -> UIElementFactory? {
//        return parentContext.factory(for: elementName)
//    }
//}
//
//extension HasParentContext where Self.ParentContext: HasUIElementFactoryRegistry {
//    public func factory(for elementName: String) -> UIElementFactory? {
//        return parentContext.factory(for: elementName)
//    }
//}

public extension DeserializationContext where Self: HasUIElementFactoryRegistry & HasParentContext, Self.ParentContext: HasUIElementFactoryRegistry {
    func factory(for elementName: String) -> UIElementFactory? {
        return parentContext.factory(for: elementName)
    }
}

class ComponentReferenceFactory: UIElementFactory {
    let elementName: String = ""
    let availableProperties: [PropertyDescription] = []
    let parentModuleImport: String = "Foundation"
    let isContainer: Bool = false

    func create(context: UIElementDeserializationContext) throws -> UIElement {
        return try ComponentReference(context: context)
    }

    func runtimeType() throws -> RuntimeType {
        return RuntimeType(name: try ComponentReference.runtimeType())
    }
}
