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

#if canImport(SwiftCodeGen)
import SwiftCodeGen
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

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        switch self {
        case .named(let name):
            return .constant("UIImage(named: \"\(name)\", in: __resourceBundle, compatibleWith: nil)")
        case .themed(let name):
            return .constant("theme.images.\(name)")
        }
    }
    #endif

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

    public static func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        return RuntimeType(name: "UIImage", module: "UIKit")
    }

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}
