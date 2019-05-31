//
//  SupportedPropertyType.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum RuntimePlatform {
    case iOS
    case macOS
}

public struct RuntimeType {
    public var name: String
    public var modules: [String]

    public init(name: String, module: String) {
        self.name = name
        self.modules = [module]
    }

    public init(name: String, modules: [String] = []) {
        self.name = name
        self.modules = modules
    }

    public static let unsupported = RuntimeType(name: "1$\\'0")
}

public protocol SupportedPropertyType {
    var requiresTheme: Bool { get }

    func generate(context: SupportedPropertyTypeContext) -> String

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
        assertionFailure("TODO Implement this in your class.")
        return .unsupported
    }
}

public extension SupportedPropertyType {
    var requiresTheme: Bool {
        return false
    }
}

public protocol AttributeSupportedPropertyType: SupportedPropertyType {
    static func materialize(from value: String) throws -> Self
}

public protocol ElementSupportedPropertyType: SupportedPropertyType {
    static func materialize(from element: XMLElement) throws -> Self
}

public protocol MultipleAttributeSupportedPropertyType: SupportedPropertyType {
    static func materialize(from attributes: [String: String]) throws -> Self
}

extension ElementSupportedPropertyType where Self: AttributeSupportedPropertyType {
    static func materialize(from element: XMLElement) throws -> Self {
        let text = element.text ?? ""
        return try materialize(from: text)
    }
}
