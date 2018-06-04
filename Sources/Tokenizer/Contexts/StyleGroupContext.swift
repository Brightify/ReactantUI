//
//  StyleGroupContext.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 01/06/2018.
//

import Foundation

public struct StyleGroupContext: DataContext {
    public let globalContext: GlobalContext
    public let group: StyleGroup

    public init(globalContext: GlobalContext, group: StyleGroup) {
        self.globalContext = globalContext
        self.group = group
    }

    public func localStyle(named name: String) -> String {
        return group.swiftName + "." + name
    }
}

extension StyleGroupContext: HasGlobalContext { }
