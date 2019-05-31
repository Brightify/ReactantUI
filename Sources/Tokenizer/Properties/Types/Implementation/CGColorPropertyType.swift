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

public struct CGColorPropertyType: AttributeSupportedPropertyType {
    public let color: UIColorPropertyType

    public var requiresTheme: Bool {
        return color.requiresTheme
    }

    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "\(color.generate(context: context.child(for: color))).cgColor"
    }

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

    public static let runtimeType = RuntimeType(name: "CGColor", module: "Foundation")

    public static var xsdType: XSDType {
        return Color.xsdType
    }
}
