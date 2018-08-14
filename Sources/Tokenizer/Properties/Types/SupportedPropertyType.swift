//
//  SupportedPropertyType.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public protocol SupportedPropertyType {
    var requiresTheme: Bool { get }

    func generate(context: SupportedPropertyTypeContext) -> String

    #if SanAndreas
    func dematerialize(context: SupportedPropertyTypeContext) -> String
    #endif

    #if canImport(UIKit)
    func runtimeValue(context: SupportedPropertyTypeContext) -> Any?
    #endif

    // FIXME Although it's not needed for POC of Themes, it should be implemented so that more things can be themed.
    // We would then use this to know how is the type called for generating.
    // static var runtimeType: String { get }

    // FIXME Has to be put into `AttributeSupportedPropertyType`
    static var xsdType: XSDType { get }
}

public extension SupportedPropertyType {
    public var requiresTheme: Bool {
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
