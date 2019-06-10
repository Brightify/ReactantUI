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

/**
 * Every context to be used inside a RUI file should conform to this protocol in order to function properly.
 * It's used along with `HasParentContext` and `HasGlobalContext` to resolve style names (local and global), themes, and more.
 * Conforming to `HasParentContext` is optional but highly recommended as it allows the context to use its predefined implementations.
 * Note that not conforming to `HasParentContext` will severe any connection from children contexts (those that reference your context)
 * from higher-up contexts.
 */
public protocol DataContext {
    var resourceBundle: Bundle? { get }

    func resolvedStyleName(named styleName: StyleName) -> String

    func style(named styleName: StyleName) -> Style?

    func template(named templateName: TemplateName) -> Template?

    func themed(image name: String) -> Image?

    func themed(color name: String) -> UIColorPropertyType?

    func themed(font name: String) -> Font?

    func definition(for componentType: String) throws -> ComponentDefinition

    func resolveStyle(for element: UIElement, stateProperties: [Property], from styles: [Style]) throws -> [Property]

    #if canImport(UIKit)
    func resolveStateProperty(named: String) throws -> Any?
    #endif
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

// WARNING:
// this extension and the one below are nearly identical and if you change something in this one,
// you most likely want to change it in the other extension as well
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

    public func template(named templateName: TemplateName) -> Template? {
        return parentContext.template(named: templateName)
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

    public func definition(for componentType: String) throws -> ComponentDefinition {
        return try parentContext.definition(for: componentType)
    }

    public func resolveStyle(for element: UIElement, stateProperties: [Property], from styles: [Style]) throws -> [Property] {
        return try parentContext.resolveStyle(for: element, stateProperties: stateProperties, from: styles)
    }

    #if canImport(UIKit)
    public func resolveStateProperty(named: String) throws -> Any? {
        return try parentContext.resolveStateProperty(named: named)
    }
    #endif
}

// WARNING:
// this extension and the one above are nearly identical and if you change something in this one,
// you most likely want to change it in the other extension as well
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

    public func template(named templateName: TemplateName) -> Template? {
        return parentContext.template(named: templateName)
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

    public func definition(for componentType: String) throws -> ComponentDefinition {
        return try parentContext.definition(for: componentType)
    }

    public func resolveStyle(for element: UIElement, stateProperties: [Property], from styles: [Style]) throws -> [Property] {
        return try parentContext.resolveStyle(for: element, stateProperties: stateProperties, from: styles)
    }

    #if canImport(UIKit)
    public func resolveStateProperty(named: String) throws -> Any? {
        return try parentContext.resolveStateProperty(named: named)
    }
    #endif
}
