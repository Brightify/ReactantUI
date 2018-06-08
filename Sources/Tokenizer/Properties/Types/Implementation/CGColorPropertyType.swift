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

    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "\(color.generate(context: context.sibling(for: color))).cgColor"
    }

    #if SanAndreas
    public func dematerialize() -> String {
        return color.dematerialize()
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return (color.runtimeValue(context: context.sibling(for: color)) as? UIColor)?.cgColor
    }
    #endif

    public init(color: UIColorPropertyType) {
        self.color = color
    }

    public static func materialize(from value: String) throws -> CGColorPropertyType {
        let materializedValue = try UIColorPropertyType.materialize(from: value)
        return CGColorPropertyType(color: materializedValue)
    }

    public static var xsdType: XSDType {
        return Color.xsdType
    }
}
