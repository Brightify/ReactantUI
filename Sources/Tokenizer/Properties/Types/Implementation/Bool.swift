//
//  Bool+SupportedPropertyType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

extension Bool: SupportedPropertyType {
    public var generated: String {
        return self ? "true" : "false"
    }

    #if SanAndreas
    public func dematerialize() -> String {
        return generated
    }
    #endif

    #if ReactantRuntime
    public var runtimeValue: Any? {
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
}
