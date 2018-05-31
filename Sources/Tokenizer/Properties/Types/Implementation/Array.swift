//
//  Array.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 31/05/2018.
//

import Foundation

extension Array: SupportedPropertyType where Iterator.Element: SupportedPropertyType {
    public var generated: String {
        return "[" + map { $0.generated }.joined(separator: ", ") + "]"
    }

    public var runtimeValue: Any? {
        return [] as [Element]
    }

    public static var xsdType: XSDType {
        return .builtin(.array)
    }

    public static func materialize(from value: String) throws -> Array<Element> {
        // removing spaces might be problematic, hopefully no sane `SupportedPropertyType` uses space as part of tokenizing
        // comma separation might be problematic as some types might use it inside of themselves, e.g. a point (x: 10, y: 12)
        return try value.replacingOccurrences(of: " ", with: "").components(separatedBy: ",").map { try Element.materialize(from: $0) }
    }
}
