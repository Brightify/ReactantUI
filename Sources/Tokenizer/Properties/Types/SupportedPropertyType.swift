//
//  SupportedPropertyType.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public struct RuntimeType: CustomStringConvertible, Equatable {
    public var name: String
    public var modules: Set<String>

    public var description: String {
        return name
    }

    public init(name: String) {
        self.name = name
        self.modules = []
    }

    public init(name: String, module: String) {
        self.name = name
        self.modules = [module]
    }

    public init<S: Sequence>(name: String, modules: S) where S.Element == String {
        self.name = name
        self.modules = Set(modules)
    }

    public static let unsupported = RuntimeType(name: "1$\\'0")
}

public protocol SupportedPropertyType {
    var requiresTheme: Bool { get }

    #if canImport(SwiftCodeGen)
    func generate(context: SupportedPropertyTypeContext) -> Expression
    #endif

    #if SanAndreas
    func dematerialize(context: SupportedPropertyTypeContext) -> String
    #endif

    #if canImport(UIKit)
    func runtimeValue(context: SupportedPropertyTypeContext) -> Any?
    #endif

    static func runtimeType(for platform: RuntimePlatform) -> RuntimeType

    // FIXME Has to be put into `AttributeSupportedPropertyType`
    static var xsdType: XSDType { get }
}

public extension SupportedPropertyType {
    static func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        #warning("This should be removed to ensure all children implement this method. I put here to not require implementation in all children before testing it out.")
        assertionFailure("TODO Implement this in your class: \(self).")
        return .unsupported
    }
}

public protocol HasDefaultValue {
    static var defaultValue: Self { get }
}

extension Optional: SupportedPropertyType & HasDefaultValue where Wrapped: SupportedPropertyType {
    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return self?.generate(context: context) ?? .constant("nil")
    }
    #endif

    public static var xsdType: XSDType {
        return Wrapped.xsdType
    }
    
    public static var defaultValue: Optional<Wrapped> {
        return nil
    }

    public static func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        let wrappedRuntimeType = Wrapped.runtimeType(for: platform)
        return RuntimeType(name: wrappedRuntimeType.name + "?", modules: wrappedRuntimeType.modules)
    }

    public var requiresTheme: Bool {
        return self?.requiresTheme ?? false
    }

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        if let wrapped = self {
            return wrapped.runtimeValue(context: context.child(for: wrapped))
        } else {
            return nil
        }
    }
    #endif
}

public protocol AttributeSupportedPropertyType: SupportedPropertyType {
    static func materialize(from value: String) throws -> Self
}

public extension AttributeSupportedPropertyType {
    var requiresTheme: Bool {
        return false
    }
}

extension Optional: AttributeSupportedPropertyType where Wrapped: AttributeSupportedPropertyType {
    public static func materialize(from value: String) throws -> Optional<Wrapped> {
        return try Wrapped.materialize(from: value)
    }
}

public protocol ElementSupportedPropertyType: SupportedPropertyType {
    static func materialize(from element: XMLElement) throws -> Self
}

public extension ElementSupportedPropertyType {
    var requiresTheme: Bool {
        return false
    }
}

extension Optional: ElementSupportedPropertyType where Wrapped: ElementSupportedPropertyType {
    public static func materialize(from element: XMLElement) throws -> Optional<Wrapped> {
        return try Wrapped.materialize(from: element)
    }
}

public protocol MultipleAttributeSupportedPropertyType: SupportedPropertyType {
    static func materialize(from attributes: [String: String]) throws -> Self
}

public extension MultipleAttributeSupportedPropertyType {
    var requiresTheme: Bool {
        return false
    }
}

extension Optional: MultipleAttributeSupportedPropertyType where Wrapped: MultipleAttributeSupportedPropertyType {
    public static func materialize(from attributes: [String: String]) throws -> Optional<Wrapped> {
        return try Wrapped.materialize(from: attributes)
    }
}

extension ElementSupportedPropertyType where Self: AttributeSupportedPropertyType {
    static func materialize(from element: XMLElement) throws -> Self {
        let text = element.text ?? ""
        return try materialize(from: text)
    }
}
