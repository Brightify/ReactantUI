//
//  DataContext.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 01/06/2018.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public protocol DataContext {

    var resourceBundle: Bundle? { get }

    func resolvedStyleName(named styleName: StyleName) -> String

    func style(named styleName: StyleName) -> Style?

    func themed(image name: String) -> Image?

    func themed(color name: String) -> UIColorPropertyType?

    func themed(font name: String) -> Font?
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
    public var resourceBundle: Bundle? {
        return parentContext.resourceBundle
    }

    public func resolvedStyleName(named styleName: StyleName) -> String {
        return parentContext.resolvedStyleName(named: styleName)
    }

    public func style(named styleName: StyleName) -> Style? {
        return parentContext.style(named: styleName)
    }

    public func themed(image name: String) -> Image? {
        return parentContext.themed(image: name)
    }

    public func themed(color name: String) -> UIColorPropertyType? {
        return parentContext.themed(color: name)
    }

    public func themed(font name: String) -> Font? {
        return parentContext.themed(font: name)
    }
}

extension DataContext where Self: HasParentContext, Self.ParentContext == DataContext {
    public var resourceBundle: Bundle? {
        return parentContext.resourceBundle
    }

    public func resolvedStyleName(named styleName: StyleName) -> String {
        return parentContext.resolvedStyleName(named: styleName)
    }

    public func style(named styleName: StyleName) -> Style? {
        return parentContext.style(named: styleName)
    }

    public func themed(image name: String) -> Image? {
        return parentContext.themed(image: name)
    }

    public func themed(color name: String) -> UIColorPropertyType? {
        return parentContext.themed(color: name)
    }

    public func themed(font name: String) -> Font? {
        return parentContext.themed(font: name)
    }
}
