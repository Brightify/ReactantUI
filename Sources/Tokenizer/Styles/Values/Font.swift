//
//  Font.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum Font: SupportedPropertyType {
    case system(weight: SystemFontWeight, size: Float)
    case named(String, size: Float)

    public var generated: String {
        switch self {
        case .system(let weight, let size):
            return "UIFont.systemFont(ofSize: \(size), weight: \(weight.name))"
        case .named(let name, let size):
            return "UIFont(\"\(name)\", \(size))"
        }
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
        switch self {
        case .system(let weight, let size):
            return ":\(weight.rawValue)@\(size)"
        case .named(let name, let size):
            return "\(name)@\(size)"
        }
    }
    #endif

    public static func materialize(from value: String) throws -> Font {
        let tokens = Lexer.tokenize(input: value, keepWhitespace: true)
        return try FontParser(tokens: tokens).parseSingle()
    }
}

#if ReactantRuntime
    import UIKit

    extension Font {

        public var runtimeValue: Any? {
            switch self {
            case .system(let weight, let size):
                return UIFont.systemFont(ofSize: CGFloat(size), weight: UIFont.Weight(rawValue: weight.value))
            case .named(let name, let size):
                return UIFont(name, CGFloat(size))
            }
        }
    }
#endif
