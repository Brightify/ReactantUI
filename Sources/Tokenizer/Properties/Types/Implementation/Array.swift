//
//  Array.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 31/05/2018.
//

import Foundation

extension Array: SupportedPropertyType where Iterator.Element: SupportedPropertyType {
    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "[" + map { $0.generate(context: context.sibling(for: $0)) }.joined(separator: ", ") + "]"
    }

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return [] as [Element]
    }

    public static var xsdType: XSDType {
        return .builtin(.array)
    }
}

extension Array: AttributeSupportedPropertyType where Iterator.Element: AttributeSupportedPropertyType {
    public static func materialize(from value: String) throws -> Array<Element> {
        // removing spaces might be problematic, hopefully no sane `SupportedPropertyType` uses space as part of tokenizing
        // comma separation might be problematic as some types might use it inside of themselves, e.g. a point (x: 10, y: 12)
        return try value.replacingOccurrences(of: " ", with: "").components(separatedBy: "|").map { try Element.materialize(from: $0) }
    }
}
