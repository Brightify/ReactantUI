//
//  Bool+SupportedPropertyType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension Bool: AttributeSupportedPropertyType {
    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .constant(self ? "true" : "false")
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return generate(context: context)
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return self
    }
    #endif

    public static func materialize(from value: String) throws -> Bool {
        guard let materialized = Bool(value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }

    public static var xsdType: XSDType {
        return .builtin(.boolean)
    }

    public static let runtimeType = RuntimeType(name: "Bool")
}

extension Bool: HasDefaultValue {
    public static let defaultValue: Bool = false
}
