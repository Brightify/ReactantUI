//
//  TokenizationContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import Foundation

public protocol TokenizationContext {
}

public protocol HasElementIdProvider {
    var elementIdProvider: ElementIdProvider { get }
}

public protocol CanTokenizeUIElement {
    func tokenize(element: XMLElement) throws -> UIElement?
}

public protocol CanDeserializeDefinition {
    func deserialize(element: XMLElement, type: String) throws -> ComponentDefinition
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

public protocol HasUIElementFactoryRegistry {
    func factory(for elementName: String) -> UIElementFactory?
}
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

public class ComponentTokenizationContext: TokenizationContext, HasParentContext, HasElementIdProvider, CanTokenizeUIElement,  HasUIElementFactoryRegistry, CanDeserializeDefinition {

    public let parentContext: TokenizationContext & HasUIElementFactoryRegistry & CanDeserializeDefinition
    public let type: String
    public let element: XMLElement
    public let elementIdProvider: ElementIdProvider

    public init(parentContext: TokenizationContext & HasUIElementFactoryRegistry & CanDeserializeDefinition, element: XMLElement, type: String, elementIdProvider: ElementIdProvider) {
        self.parentContext = parentContext
        self.element = element
        self.elementIdProvider = elementIdProvider
    }

    public func tokenize(element: XMLElement) throws -> UIElement? {
        if let factory = parentContext.factory(for: element.name) {
            return try factory.create(context: child(element: element))
        } else {
            return nil
        }
    }

    private func child(element: XMLElement) -> UIElementTokenizationContext {
        return UIElementTokenizationContext(parentContext: self, element: element, elementIdProvider: elementIdProvider)
    }

    public func deserialize(element: XMLElement, type: String) throws -> ComponentDefinition {
        return try parentContext.deserialize(element: element, type: type)
    }

    public func factory(for elementName: String) -> UIElementFactory? {
        return parentContext.factory(for: elementName)
    }

//    public static func deserialize(nodes: [XMLElement], idProvider: ElementIdProvider) throws -> [UIElement] {
//        return try nodes.compactMap { node -> UIElement? in
//
//        }
//    }
}

public class UIElementTokenizationContext: TokenizationContext, HasParentContext, HasElementIdProvider, CanTokenizeUIElement, HasUIElementFactoryRegistry, CanDeserializeDefinition {
    public let parentContext: TokenizationContext & HasUIElementFactoryRegistry & CanDeserializeDefinition
    public let element: XMLElement
    public let elementIdProvider: ElementIdProvider

    public init(parentContext: TokenizationContext & HasUIElementFactoryRegistry & CanDeserializeDefinition, element: XMLElement, elementIdProvider: ElementIdProvider) {
        self.parentContext = parentContext
        self.element = element
        self.elementIdProvider = elementIdProvider
    }

    public func tokenize(element: XMLElement) throws -> UIElement? {
        return try parentContext.factory(for: element.name)?.create(context: child(element: element))
    }

    private func child(element: XMLElement) -> UIElementTokenizationContext {
        return UIElementTokenizationContext(parentContext: self, element: element, elementIdProvider: elementIdProvider.child())
    }

    public func factory(for elementName: String) -> UIElementFactory? {
        return parentContext.factory(for: elementName)
    }

    public func deserialize(element: XMLElement, type: String) throws -> ComponentDefinition {
        return try parentContext.deserialize(element: element, type: type)
    }
}

public class StyleTokenizationContext: TokenizationContext, HasParentContext {
    public let parentContext: TokenizationContext & CanTokenizeUIElement
    public let element: XMLElement
    public let groupName: String?

    public init(parentContext: TokenizationContext & CanTokenizeUIElement, element: XMLElement, groupName: String?) {
        self.parentContext = parentContext
        self.element = element
        self.groupName = groupName
    }

    public func tokenize(element: XMLElement) throws -> UIElement? {
        return try parentContext.tokenize(element: element)
    }
}

public class GlobalTokenizationContext: TokenizationContext, HasUIElementFactoryRegistry, CanDeserializeDefinition {
    public let elementFactories: [String: UIElementFactory]

    init(elementFactories: [UIElementFactory]) {
        self.elementFactories = Dictionary(uniqueKeysWithValues: elementFactories.map { ($0.elementName, $0) })
    }

    public func factory(for elementName: String) -> UIElementFactory? {
        if elementName == "styles" || elementName == "templates" {
            return nil
        } else if let elementFactory = elementFactories[elementName] {
            return elementFactory
        } else {
            return ComponentReferenceFactory()
        }
    }

    public func deserialize(element: XMLElement, type: String) throws -> ComponentDefinition {
        let context = ComponentTokenizationContext(parentContext: self, element: element, type: type, elementIdProvider: ElementIdProvider(prefix: ""))
        return try ComponentDefinition(context: context)
    }
}

class ComponentReferenceFactory: UIElementFactory {
    let elementName: String = ""

    func create(context: UIElementTokenizationContext) throws -> UIElement {
        return try ComponentReference(context: context)
    }
}
