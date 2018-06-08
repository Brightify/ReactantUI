//
//  DataContext.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 01/06/2018.
//

import Foundation

public protocol DataContext {

    func localStyle(named name: String) -> String

    func style(named styleName: StyleName) -> Style?
}

public protocol HasParentContext {
    associatedtype ParentContext

    var parentContext: ParentContext { get }
}

public protocol HasGlobalContext: HasParentContext {
    var globalContext: GlobalContext { get }
}

extension HasParentContext where Self: HasGlobalContext {
    public var parentContext: GlobalContext {
        return globalContext
    }
}

extension DataContext where Self: HasParentContext, Self.ParentContext: DataContext {
    public func localStyle(named name: String) -> String {
        return parentContext.localStyle(named: name)
    }

    public func style(named styleName: StyleName) -> Style? {
        return parentContext.style(named: styleName)
    }
}

extension DataContext where Self: HasParentContext, Self.ParentContext == DataContext {
    public func localStyle(named name: String) -> String {
        return parentContext.localStyle(named: name)
    }

    public func style(named styleName: StyleName) -> Style? {
        return parentContext.style(named: styleName)
    }
}
