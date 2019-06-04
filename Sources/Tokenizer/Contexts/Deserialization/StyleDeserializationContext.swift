//
//  StyleDeserializationContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 03/06/2019.
//

import Foundation

public class StyleDeserializationContext: DeserializationContext, HasParentContext {
    public let parentContext: DeserializationContext & HasUIElementFactoryRegistry
    public let element: XMLElement
    public let groupName: String?

    public init(parentContext: DeserializationContext & HasUIElementFactoryRegistry, element: XMLElement, groupName: String?) {
        self.parentContext = parentContext
        self.element = element
        self.groupName = groupName
    }
}

extension StyleDeserializationContext: HasUIElementFactoryRegistry {
    public func factory(for elementName: String) -> UIElementFactory? {
        return parentContext.factory(for: elementName)
    }
}
