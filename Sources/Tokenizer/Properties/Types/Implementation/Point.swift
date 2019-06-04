//
//  Point.swift
//  Hyperdrive
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public struct Point: AttributeSupportedPropertyType {
    public static let zero = Point(x: 0, y: 0)

    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .constant("CGPoint(x: \(x.cgFloat), y: \(y.cgFloat))")
    }
    #endif
    
    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return "x: \(x), y: \(y)"
    }
    #endif

    public static func materialize(from value: String) throws -> Point {
        let dimensions = try DimensionParser(tokens: Lexer.tokenize(input: value)).parse()

        guard dimensions.count == 2 else {
            throw PropertyMaterializationError.unknownValue(value)
        }

        let x = (dimensions.first(where: { $0.identifier == "x" }) ?? dimensions[0]).value
        let y = (dimensions.first(where: { $0.identifier == "y" }) ?? dimensions[1]).value

        return Point(x: x, y: y)
    }

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}

#if canImport(UIKit)
    extension Point {

        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            return CGPoint(x: x.cgFloat, y: y.cgFloat)
        }
    }
#endif
