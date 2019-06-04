//
//  Int+SupportedPropertyType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

extension Int: AttributeSupportedPropertyType {
    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .constant("\(self)")
    }
    #endif

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

    public static func materialize(from value: String) throws -> Int {
        guard let materialized = Int(value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }

    public static var xsdType: XSDType {
        return .builtin(.integer)
    }

    public static func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        return RuntimeType(name: "Int")
    }
}

extension Int: HasDefaultValue {
    public static let defaultValue: Int = 0
}
