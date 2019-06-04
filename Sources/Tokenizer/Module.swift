//
//  Module.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import Foundation

public struct Module {
    
}

public protocol UIElementFactory {
    var elementName: String { get }

    #warning("REMOVEME Rewrite handling imports")
    var parentModuleImport: String { get }

    var availableProperties: [PropertyDescription] { get }

    var isContainer: Bool { get }

    func create(context: UIElementDeserializationContext) throws -> UIElement

    func runtimeType() throws -> RuntimeType
}

public protocol RuntimeModule {
    var supportedPlatforms: Set<RuntimePlatform> { get }

    func elements(for platform: RuntimePlatform) -> [UIElementFactory]
}

extension RuntimeModule {
    public func factory<T: View>(named name: String, for initializer: @escaping (UIElementDeserializationContext) throws -> T) -> UIElementFactory {
        return UIKitUIElementFactory(name: name, initializer: initializer)
    }
}

private class UIKitUIElementFactory<VIEW: View>: UIElementFactory {
    let elementName: String
    let initializer: (UIElementDeserializationContext) throws -> VIEW

    var availableProperties: [PropertyDescription] {
        return VIEW.availableProperties
    }

    var parentModuleImport: String {
        return VIEW.parentModuleImport
    }

    var isContainer: Bool {
        return VIEW.self is UIContainer.Type
    }

    init(name: String, initializer: @escaping (UIElementDeserializationContext) throws -> VIEW) {
        elementName = name
        self.initializer = initializer
    }

    func create(context: UIElementDeserializationContext) throws -> UIElement {
        return try initializer(context)
    }

    func runtimeType() throws -> RuntimeType {
        return RuntimeType(name: try VIEW.runtimeType())
    }
}

