//
//  Array.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 31/05/2018.
//

import Foundation

extension Array: SupportedPropertyType where Iterator.Element: SupportedPropertyType {
    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "[" + map { $0.generate(context: context.child(for: $0)) }.joined(separator: ", ") + "]"
    }

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return map { $0.runtimeValue(context: context.child(for: $0)) }
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return map { $0.dematerialize(context: context.child(for: $0)) }.joined(separator: ";")
    }
    #endif

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}

extension Array: AttributeSupportedPropertyType where Iterator.Element: AttributeSupportedPropertyType {
    public static func materialize(from value: String) throws -> Array<Element> {
        // removing spaces might be problematic, hopefully no sane `SupportedPropertyType` uses space as part of tokenizing
        // comma separation might be problematic as some types might use it inside of themselves, e.g. a point (x: 10, y: 12)
        return try value.replacingOccurrences(of: " ", with: "").components(separatedBy: ";").map { try Element.materialize(from: $0) }
    }
}
