//
//  URL.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 28/05/2018.
//

import Foundation

extension URL: AttributeSupportedPropertyType {
    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "\(self.absoluteString)"
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
