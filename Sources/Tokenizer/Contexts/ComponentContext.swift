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
}
