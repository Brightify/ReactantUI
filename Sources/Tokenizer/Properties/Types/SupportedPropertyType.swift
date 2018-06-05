//
//  SupportedPropertyType.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public protocol SupportedPropertyType {
    func generate(context: SupportedPropertyTypeContext) -> String

    #if SanAndreas
    func dematerialize(context: SupportedPropertyTypeContext) -> String
    #endif

    #if ReactantRuntime
    func runtimeValue(context: SupportedPropertyTypeContext) -> Any?
    #endif

    // FIXME Has to be put into `AttributeSupportedPropertyType
    static var xsdType: XSDType { get }
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
