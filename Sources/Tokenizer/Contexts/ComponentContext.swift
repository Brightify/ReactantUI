//
//  ComponentContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

public struct ComponentContext: DataContext {
    public let globalContext: GlobalContext
    public let component: ComponentDefinition

    public init(globalContext: GlobalContext, component: ComponentDefinition) {
        self.globalContext = globalContext
        self.component = component
    }

    public func localStyle(named name: String) -> String {
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
