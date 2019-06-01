//
//  Size.swift
//  Hyperdrive
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct Size: AttributeSupportedPropertyType {
    public static let zero = Size(width: 0, height: 0)

    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "CGSize(width: \(CGFloat(width)), height: \(CGFloat(height))"
    }
    
    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return "width: \(width), height: \(height)"
    }
    #endif

    public static func materialize(from value: String) throws -> Size {
        let dimensions = try DimensionParser(tokens: Lexer.tokenize(input: value)).parse()
        if let singleDimension = dimensions.first, dimensions.count == 1 {
            return Size(width: singleDimension.value, height: singleDimension.value)
        } else if dimensions.count == 2 {
            let width = (dimensions.first(where: { $0.identifier == "width" }) ?? dimensions[0]).value
            let height = (dimensions.first(where: { $0.identifier == "height" }) ?? dimensions[1]).value
            return Size(width: width, height: height)
        } else {
            throw PropertyMaterializationError.unknownValue(value)
        }
    }

    public static var xsdType: XSDType {
        return .builtin(.decimal)
    }
}

#if canImport(UIKit)
    import UIKit

    extension Size {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            return CGSize(width: width.cgFloat, height: height.cgFloat)
        }
    }
#endif
