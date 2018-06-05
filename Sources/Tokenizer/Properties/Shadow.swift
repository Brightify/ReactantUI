//
//  Shadow.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import Foundation

public struct Shadow: MultipleAttributeSupportedPropertyType {
    public let offset: Size
    public let blurRadius: Float
    public let color: UIColorPropertyType?

    public func generate(context: SupportedPropertyTypeContext) -> String {
        let generatedOffset = offset.generate(context: context.sibling(for: offset))
        let generatedBlurRadius = blurRadius.generate(context: context.sibling(for: blurRadius))
        let generatedColor = color.map { $0.generate(context: context.sibling(for: $0)) } ?? "nil"
        return "NSShadow(offset: \(generatedOffset), blurRadius: \(generatedBlurRadius), color: \(generatedColor))"
    }

    #if SanAndreas
    public func dematerialize() -> String {
        return "width: \(width), height: \(height)"
    }
    #endif

    public static func materialize(from attributes: [String : String]) throws -> Shadow {
        let offset = try attributes["offset"].map(Size.materialize) ?? Size.zero
        let blurRadius = try attributes["blurRadius"].map(Float.materialize) ?? 0
        let color = try attributes["color"].map(UIColorPropertyType.materialize)

        return Shadow(offset: offset, blurRadius: blurRadius, color: color)
    }

    public static var xsdType: XSDType {
        return .builtin(.decimal)
    }
}

#if ReactantRuntime
import UIKit

extension NSShadow {
    public convenience init(offset: CGSize?, blurRadius: CGFloat, color: UIColor?) {
        self.init()
        if let offset = offset {
            self.shadowOffset = offset
        }
        self.shadowBlurRadius = blurRadius
        if let color = color {
            self.shadowColor = color
        }
    }
}

extension Shadow {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        let offsetValue = offset.runtimeValue(context: context.sibling(for: offset)).flatMap { $0 as? CGSize }
        let colorValue = color.flatMap { $0.runtimeValue(context: context.sibling(for: $0)) }.flatMap { $0 as? UIColor }
        return NSShadow(offset: offsetValue, blurRadius: CGFloat(blurRadius), color: colorValue)
    }
}
#endif
