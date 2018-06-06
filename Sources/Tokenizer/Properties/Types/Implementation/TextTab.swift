//
//  TextTab.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import Foundation

public struct TextTab: AttributeSupportedPropertyType {
    public let textAlignment: TextAlignment
    public let location: Float

    public static func materialize(from value: String) throws -> TextTab {
        let components = value.components(separatedBy: "@")
        switch components.count {
        case 2:
            let (textAlignment, location) = try (TextAlignment.materialize(from: components[0]), Float.materialize(from: components[1]))
            return TextTab(textAlignment: textAlignment, location: location)
        case 1:
            let location = try Float.materialize(from: components[0])
            return TextTab(textAlignment: .left, location: location)
        default:
            throw XMLDeserializationError.NodeHasNoValue
        }
    }

    public func generate(context: SupportedPropertyTypeContext) -> String {
        let generatedTextAlignment = textAlignment.generate(context: context.sibling(for: textAlignment))
        let generatedLocation = location.generate(context: context.sibling(for: location))
        return "NSTextTab(textAlignment: \(generatedTextAlignment), location: \(generatedLocation))"
    }

    #if SanAndreas
    public func dematerialize() -> String {
        // TODO: format - "center@4"
        return ""
    }
    #endif

    public static var xsdType: XSDType {
        return .pattern(PatternXSDType(name: "TextTab", base: .string, value: "??"))
    }
}

#if ReactantRuntime
import UIKit

extension TextTab {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        guard let textAlignmentRawValue = textAlignment.runtimeValue(context: context.sibling(for: textAlignment)) as? Int,
           let textAlignmentValue = NSTextAlignment(rawValue: textAlignmentRawValue) else { return nil }
        return NSTextTab(textAlignment: textAlignmentValue, location: CGFloat(location))
    }
}
#endif
