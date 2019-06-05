//
//  StyleGroupContext.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 01/06/2018.
//

import Foundation

/**
 * Context connected to a style group either in a component or in the global scope.
 */
public class StyleGroupContext: DataContext {
    public let globalContext: GlobalContext
    public let group: StyleGroup

    public init(globalContext: GlobalContext, group: StyleGroup) {
        self.globalContext = globalContext
        self.group = group
    }

    public func resolvedStyleName(named styleName: StyleName) -> String {
        return group.swiftName + "." + styleName.name
    }

    public func style(named styleName: StyleName) -> Style? {
        guard case .global(let groupName, let name) = styleName, groupName == group.name else {
            return globalContext.style(named: styleName)
        }

        return group.styles.first { $0.name.name == name }
    }
}

extension StyleGroupContext: HasGlobalContext { }
