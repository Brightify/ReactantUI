//
//  ComponentDeserializationContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 03/06/2019.
//

import Foundation

public class ComponentDeserializationContext: DeserializationContext, HasParentContext, HasElementIdProvider {

    public let parentContext: DeserializationContext & HasUIElementFactoryRegistry & CanDeserializeDefinition
    public let type: String
    public let element: XMLElement
    public let elementIdProvider: ElementIdProvider

    public init(parentContext: DeserializationContext & HasUIElementFactoryRegistry & CanDeserializeDefinition, element: XMLElement, type: String, elementIdProvider: ElementIdProvider) {
        self.parentContext = parentContext
        self.type = type
        self.element = element
        self.elementIdProvider = elementIdProvider
    }
}

extension ComponentDeserializationContext: CanDeserializeUIElement {
    public func deserialize(element: XMLElement) throws -> UIElement? {
        if let factory = parentContext.factory(for: element.name) {
            return try factory.create(context: child(element: element))
        } else {
            return nil
        }
    }

    private func child(element: XMLElement) -> UIElementDeserializationContext {
        return UIElementDeserializationContext(parentContext: self, element: element, elementIdProvider: elementIdProvider)
    }
}

extension ComponentDeserializationContext: HasUIElementFactoryRegistry {
    public func factory(for elementName: String) -> UIElementFactory? {
        return parentContext.factory(for: elementName)
    }
}

extension ComponentDeserializationContext: CanDeserializeDefinition {
    public func deserialize(element: XMLElement, type: String) throws -> ComponentDefinition {
        return try parentContext.deserialize(element: element, type: type)
    }
}

extension ComponentDeserializationContext: CanDeserializeStyleElement {
    public func deserialize(element: XMLElement, groupName: String?) throws -> Style {
        return try Style(context: child(element: element, groupName: groupName))
    }

    private func child(element: XMLElement, groupName: String?) -> StyleDeserializationContext {
        return StyleDeserializationContext(parentContext: self, element: element, groupName: groupName)
    }
}
