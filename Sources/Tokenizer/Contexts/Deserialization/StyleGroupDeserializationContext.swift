//
//  StyleGroupDeserializationContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 03/06/2019.
//

import Foundation

public class StyleGroupDeserializationContext: DeserializationContext, HasParentContext {
    public let parentContext: DeserializationContext & HasUIElementFactoryRegistry
    public let element: XMLElement

    public init(parentContext: DeserializationContext & HasUIElementFactoryRegistry, element: XMLElement) {
        self.parentContext = parentContext
        self.element = element
    }
}

extension StyleGroupDeserializationContext: HasUIElementFactoryRegistry {
    public func factory(for elementName: String) -> UIElementFactory? {
        return parentContext.factory(for: elementName)
    }
}

extension StyleGroupDeserializationContext: CanDeserializeStyleElement {
    public func deserialize(element: XMLElement, groupName: String?) throws -> Style {
        return try Style(context: child(element: element, groupName: groupName))
    }

    private func child(element: XMLElement, groupName: String?) -> StyleDeserializationContext {
        return StyleDeserializationContext(parentContext: self, element: element, groupName: groupName)
    }
}
