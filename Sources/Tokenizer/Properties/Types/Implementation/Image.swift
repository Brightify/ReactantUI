//
//  Image.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public struct Image: AttributeSupportedPropertyType {
    public let name: String

    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "UIImage(named: \"\(name)\")"
    }

    #if ReactantRuntime
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return UIImage(named: name)
    }
    #endif

    #if SanAndreas
    public func dematerialize() -> String {
        return name
    }
    #endif

    public init(named name: String) {
        self.name = name
    }

    public static func materialize(from value: String) throws -> Image {
        return Image(named: value)
    }

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}
