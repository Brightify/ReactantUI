//
//  Point.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif

public struct Point: AttributeSupportedPropertyType {
    public let x: Float
    public let y: Float
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }

    public init(x: Double, y: Double) {
        self.x = Float(x)
        self.y = Float(y)
    }

    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "CGPoint(x: \(x.cgFloat), y: \(y.cgFloat))"
    }
    
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
