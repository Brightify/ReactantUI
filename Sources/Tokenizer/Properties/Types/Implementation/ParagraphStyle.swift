//
//  ParagraphStyle.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import Foundation

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public struct ParagraphStyle: MultipleAttributeSupportedPropertyType {
    public let properties: [Property]

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        var block = Block()
        block += .declaration(isConstant: true, name: "p", expression: .constant("NSMutableParagraphStyle()"))

        for property in properties {
            block += .assignment(
                target: .member(target: .constant("p"), name: property.name),
                expression: property.anyValue.generate(context: context.child(for: property.anyValue)))
        }

        block += .return(expression: .constant("p"))

        let closure = Closure(block: block)

        return .invoke(target: .closure(closure), arguments: [])
    }
    #endif

    #if SanAndreas
    // TODO
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        fatalError("Implement me!")
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
            let value = property.anyValue.runtimeValue(context: context.child(for: property.anyValue))
            paragraphStyle.setValue(value, forKey: property.name)
        }
        return paragraphStyle
    }
}
#endif
