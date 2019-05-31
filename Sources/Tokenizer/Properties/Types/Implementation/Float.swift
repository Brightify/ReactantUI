//
//  Float+SupportedPropertyType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

extension Float: AttributeSupportedPropertyType {

    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "\(self)"
    }

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return self
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return generate(context: context)
    }
    #endif

    public static func materialize(from value: String) throws -> Float {
        guard let materialized = Float(value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }

    public static let runtimeType = RuntimeType(name: "Float")

    public static var xsdType: XSDType {
        return .builtin(.decimal)
    }
}
