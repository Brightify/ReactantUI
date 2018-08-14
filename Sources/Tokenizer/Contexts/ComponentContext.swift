//
//  ComponentContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

/**
 * The "file"'s context. This context is available throughout a Component's file.
 * It's used to resolve local styles and delegate global style resolving to global context.
 */
public struct ComponentContext: DataContext {
    public let globalContext: GlobalContext
    public let component: ComponentDefinition

    public init(globalContext: GlobalContext, component: ComponentDefinition) {
        self.globalContext = globalContext
        self.component = component
    }

    public func resolvedStyleName(named styleName: StyleName) -> String {
        guard case .local(let name) = styleName else {
            return globalContext.resolvedStyleName(named: styleName)
        }
        return component.stylesName + "." + name
    }

    public func style(named styleName: StyleName) -> Style? {
        guard case .local(let name) = styleName else {
            return globalContext.style(named: styleName)
        }
        return component.styles.first { $0.name.name == name }
    }
}

extension ComponentContext: HasGlobalContext { }
