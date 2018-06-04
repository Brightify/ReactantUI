//
//  SupportedPropertyType.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public protocol SupportedPropertyType {
    var generated: String { get }

    #if SanAndreas
    func dematerialize() -> String
    #endif

    #if ReactantRuntime
    var runtimeValue: Any? { get }
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

extension ElementSupportedPropertyType where Self: AttributeSupportedPropertyType {
    static func materialize(from element: XMLElement) throws -> Self {
        let text = element.text ?? ""
        return try materialize(from: text)
    }
}
