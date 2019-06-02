//
//  Module.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import Foundation

public struct Module {
    
}

public protocol RuntimeModule {
    var supportedPlatforms: Set<RuntimePlatform> { get }

    func elements(for platform: RuntimePlatform) -> [UIElementFactory]
}

extension RuntimeModule {
    public func factory<T: UIElement>(named name: String, for initializer: @escaping (UIElementTokenizationContext) throws -> T) -> UIElementFactory {

        return DefaultUIElementFactory(name: name, initializer: initializer)
    }
}

public protocol UIElementFactory {
    var elementName: String { get }

    func create(context: UIElementTokenizationContext) throws -> UIElement
}

private class DefaultUIElementFactory: UIElementFactory {
    let elementName: String
    let typeIdentifier: ObjectIdentifier
    let initializer: (UIElementTokenizationContext) throws -> UIElement

    init<T: UIElement>(name: String, initializer: @escaping (UIElementTokenizationContext) throws -> T) {
        elementName = name
        typeIdentifier = ObjectIdentifier(T.self)
        self.initializer = initializer
    }

    func create(context: UIElementTokenizationContext) throws -> UIElement {
        return try initializer(context)
    }
}
