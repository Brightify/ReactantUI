//
//  ElementContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

public struct ElementContext: DataContext {
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
