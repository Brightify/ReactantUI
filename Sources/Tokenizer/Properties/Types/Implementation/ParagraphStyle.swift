//
//  ParagraphStyle.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import Foundation

public struct ParagraphStyle: MultipleAttributeSupportedPropertyType {
    public let properties: [Property]

    public func generate(context: SupportedPropertyTypeContext) -> String {
        return """
        {
            let p = NSMutableParagraphStyle()
            \(properties.map { "p.\($0.name) = \($0.anyValue.generate(context: context.sibling(for: $0.anyValue)))" }.joined(separator: "\n"))
            return p
        }()
        """
    }

    #if SanAndreas
    // TODO
    public func dematerialize() -> String {
        return ""
    }
    #endif

    public static func materialize(from attributes: [String: String]) throws -> ParagraphStyle {
        let properties = Properties.paragraphStyle.allProperties.compactMap { $0 as? AttributePropertyDescription }

        return try ParagraphStyle(properties: PropertyHelper.deserializeSupportedProperties(properties: properties, from: attributes))
    }

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}

#if canImport(UIKit)
import UIKit

extension ParagraphStyle {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        let paragraphStyle = NSMutableParagraphStyle()
        for property in properties {
            let value = property.anyValue.runtimeValue(context: context.sibling(for: property.anyValue))
            paragraphStyle.setValue(value, forKey: property.name)
        }
        return paragraphStyle
    }
}
#endif
