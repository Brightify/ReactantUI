//
//  UIElementDeserializationContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 03/06/2019.
//

import Foundation

public class UIElementDeserializationContext: DeserializationContext, HasParentContext, HasElementIdProvider {
    public let parentContext: DeserializationContext & HasUIElementFactoryRegistry & CanDeserializeDefinition
    public let element: XMLElement
    public let elementIdProvider: ElementIdProvider

    public init(parentContext: DeserializationContext & HasUIElementFactoryRegistry & CanDeserializeDefinition, element: XMLElement, elementIdProvider: ElementIdProvider) {
        self.parentContext = parentContext
        self.element = element
        self.elementIdProvider = elementIdProvider
    }
}

extension UIElementDeserializationContext: CanDeserializeUIElement {
    public func deserialize(element: XMLElement) throws -> UIElement? {
        return try parentContext.factory(for: element.name)?.create(context: child(element: element))
    }

    private func child(element: XMLElement) -> UIElementDeserializationContext {
        return UIElementDeserializationContext(parentContext: self, element: element, elementIdProvider: elementIdProvider.child())
    }
}

extension UIElementDeserializationContext: CanDeserializeDefinition {
    public func deserialize(element: XMLElement, type: String) throws -> ComponentDefinition {
        return try parentContext.deserialize(element: element, type: type)
    }
}

extension UIElementDeserializationContext: HasUIElementFactoryRegistry {
    public func factory(for elementName: String) -> UIElementFactory? {
        return parentContext.factory(for: elementName)
    }
}
