//
//  ParagraphStyle.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import Foundation

public struct ParagraphStyle: MultipleAttributeSupportedPropertyType {
//    public let alignment: TextAlignment
//    public let firstLineHeadIndent: Float
//    public let headIndent: Float
//    public let tailIndent: Float
//    public let tabStops: [TextTab]
//    public let lineBreakMode: LineBreakMode
//    public let maximumLineHeight: Float
//    public let minimumLineHeight: Float
//    public let lineHeightMultiple: Float
//    public let lineSpacing: Float
//    public let paragraphSpacing: Float
//    public let paragraphSpacingBefore: Float
    public let properties: [Property]

    public func generate(context: SupportedPropertyTypeContext) -> String {
//        func f<T: Defaultable & AttributeSupportedPropertyType>(value: T) -> Bool {
//            return false
//        }
//
//        let modifiedValues = ([
//            alignment, firstLineHeadIndent, headIndent, tailIndent,
//            lineBreakMode, maximumLineHeight, minimumLineHeight,
//            lineHeightMultiple, lineSpacing, paragraphSpacing, paragraphSpacingBefore
//        ] as [AttributeSupportedPropertyType])

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
//        let alignment = try attributes["alignment"].map(TextAlignment.materialize) ?? TextAlignment.left
//        let firstLineHeadIndent = try attributes["firstLineHeadIndent"].map(Float.materialize) ?? 0
//        let headIndent = try attributes["headIndent"].map(Float.materialize) ?? 0
//        let tailIndent = try attributes["tailIndent"].map(Float.materialize) ?? 0
//        let tabStops = try attributes["tabStops"].map([TextTab].materialize) ?? [TextTab].defaultValue
//        let lineBreakMode = try attributes["lineBreakMode"].map(LineBreakMode.materialize) ?? LineBreakMode.byWordWrapping
//        let maximumLineHeight = try attributes["maximumLineHeight"].map(Float.materialize) ?? 0
//        let minimumLineHeight = try attributes["minimumLineHeight"].map(Float.materialize) ?? 0
//        let lineHeightMultiple = try attributes["lineHeightMultiple"].map(Float.materialize) ?? 0
//        let lineSpacing = try attributes["lineSpacing"].map(Float.materialize) ?? 0
//        let paragraphSpacing = try attributes["paragraphSpacing"].map(Float.materialize) ?? 0
//        let paragraphSpacingBefore = try attributes["paragraphSpacingBefore"].map(Float.materialize) ?? 0

        let properties = Properties.paragraphStyle.allProperties.compactMap { $0 as? AttributePropertyDescription }

        return try ParagraphStyle(properties: PropertyHelper.deserializeSupportedProperties(properties: properties, from: attributes))

//        return ParagraphStyle(
//            alignment: alignment,
//            firstLineHeadIndent: firstLineHeadIndent,
//            headIndent: headIndent,
//            tailIndent: tailIndent,
//            tabStops: tabStops,
//            lineBreakMode: lineBreakMode,
//            maximumLineHeight: maximumLineHeight,
//            minimumLineHeight: minimumLineHeight,
//            lineHeightMultiple: lineHeightMultiple,
//            lineSpacing: lineSpacing,
//            paragraphSpacing: paragraphSpacing,
//            paragraphSpacingBefore: paragraphSpacingBefore
//        )
    }

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}

#if ReactantRuntime
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
