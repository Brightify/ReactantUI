//
//  MainDeserializationContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 03/06/2019.
//

import Foundation

public class MainDeserializationContext: DeserializationContext {
    public let elementFactories: [String: UIElementFactory]

    public init(elementFactories: [UIElementFactory]) {
        self.elementFactories = Dictionary(uniqueKeysWithValues: elementFactories.map { ($0.elementName, $0) })
    }
}

extension MainDeserializationContext: HasUIElementFactoryRegistry {
    public func factory(for elementName: String) -> UIElementFactory? {
        if elementName == "styles" || elementName == "templates" {
            return nil
        } else if let elementFactory = elementFactories[elementName] {
            return elementFactory
        } else {
            return ComponentReferenceFactory()
        }
    }
}

extension MainDeserializationContext: CanDeserializeDefinition {
    public func deserialize(element: XMLElement, type: String) throws -> ComponentDefinition {
        let context = ComponentDeserializationContext(parentContext: self, element: element, type: type, elementIdProvider: ElementIdProvider(prefix: ""))
        return try ComponentDefinition(context: context)
    }
}

extension MainDeserializationContext: CanDeserializeStyleGroup {
    public func deserialize(element: XMLElement) throws -> StyleGroup {
        let context = StyleGroupDeserializationContext(parentContext: self, element: element)
        return try StyleGroup(context: context)
    }
}
