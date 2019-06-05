//
//  ElementContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

/**
 * Context inside a single UI element. It needs the element to which the context should be connected.
 * Has direct connection to `ComponentContext`, not just the `DataContext` handle.
 */
public class ElementContext: DataContext {
    public let componentContext: ComponentContext
    // FIXME It'd be better to use UIElement instead of UIElementBase, but ComponentDefinition isn't a class so it can't implement UIElement
    public let element: UIElementBase

    public init(componentContext: ComponentContext, element: UIElementBase) {
        self.componentContext = componentContext
        self.element = element
    }
}

extension ElementContext: HasParentContext {
    public var parentContext: ComponentContext {
        return componentContext
    }
}
