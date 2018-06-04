//
//  URL.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 28/05/2018.
//

import Foundation

extension URL: AttributeSupportedPropertyType {
    public var generated: String {
        return "\(self.absoluteString)"
    }

    #if ReactantRuntime
    public var runtimeValue: Any? {
        return self
    }
    #endif

    #if SanAndreas
    public func dematerialize() -> String {
        return generated
    }
    #endif

    public static func materialize(from value: String) throws -> URL {
        guard let materialized = URL(string: value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }

    public static var xsdType: XSDType {
        // PR: is it, really?
        return .builtin(.string)
    }
}
