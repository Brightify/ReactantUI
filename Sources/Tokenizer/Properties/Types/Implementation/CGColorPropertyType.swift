//
//  CGColorPropertyType.swift
//  ReactantUIGenerator
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

public struct CGColorPropertyType: AttributeSupportedPropertyType {
    public static let black = CGColorPropertyType(color: .color(.black))

    public let color: UIColorPropertyType

    public var requiresTheme: Bool {
        return color.requiresTheme
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .member(target: color.generate(context: context.child(for: color)), name: "cgColor")
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return color.dematerialize(context: context.child(for: color))
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return (color.runtimeValue(context: context.child(for: color)) as? UIColor)?.cgColor
    }
    #endif

    public init(color: UIColorPropertyType) {
        self.color = color
    }

    public static func materialize(from value: String) throws -> CGColorPropertyType {
        let materializedValue = try UIColorPropertyType.materialize(from: value)
        return CGColorPropertyType(color: materializedValue)
    }

    public static func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        return RuntimeType(name: "CGColor", module: "Foundation")
    }

    public static var xsdType: XSDType {
        return Color.xsdType
    }
}
