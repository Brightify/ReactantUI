//
//  Image.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public enum Image: AttributeSupportedPropertyType {
    case named(String)
    case themed(String)

    public var requiresTheme: Bool {
        switch self {
        case .named:
            return false
        case .themed:
            return true
        }
    }

    public func generate(context: SupportedPropertyTypeContext) -> String {
        switch self {
        case .named(let name):
            return "UIImage(named: \"\(name)\", in: __resourceBundle, compatibleWith: nil)"
        case .themed(let name):
            return "theme.images.\(name)"
        }

    }

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .named(let name):
            return UIImage(named: name)
        case .themed(let name):
            guard let themedImage = context.themed(image: name) else { return nil }
            return themedImage.runtimeValue(context: context.child(for: themedImage))
        }
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return name
    }
    #endif

    public static func materialize(from value: String) throws -> Image {
        if let themedName = ApplicationDescription.themedValueName(value: value) {
            return .themed(themedName)
        } else {
            return .named(value)
        }
    }

    public static var runtimeType: String = "UIImage"

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}
