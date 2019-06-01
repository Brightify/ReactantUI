//
//  Rect.swift
//  Hyperdrive
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif

public struct Rect: AttributeSupportedPropertyType {
    public static let zero = Rect()

    public let origin: Point
    public let size: Size

    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "CGRect(origin: CGPoint(x: \(origin.x.cgFloat), y: \(origin.y.cgFloat)), size: CGSize(width: \(size.width.cgFloat), height: \(size.height.cgFloat)))"
    }

    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }

    public init(x: Double = 0, y: Double = 0, width: Double = 0, height: Double = 0) {
        self.init(origin: Point(x: x, y: y), size: Size(width: width, height: height))
    }
    
    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return "x: \(origin.x), y: \(origin.y), width: \(size.width), height: \(size.height)"
    }
    #endif

    public static func materialize(from value: String) throws -> Rect {
        let dimensions = try DimensionParser(tokens: Lexer.tokenize(input: value)).parse()
        guard dimensions.count == 4 else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        let x = (dimensions.first(where: { $0.identifier == "x" }) ?? dimensions[0]).value
        let y = (dimensions.first(where: { $0.identifier == "y" }) ?? dimensions[1]).value
        let width = (dimensions.first(where: { $0.identifier == "width" }) ?? dimensions[2]).value
        let height = (dimensions.first(where: { $0.identifier == "height" }) ?? dimensions[3]).value
        return Rect(x: x, y: y, width: width, height: height)
    }

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}

#if canImport(UIKit)

    extension Rect {
        public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
            let origin = CGPoint(x: self.origin.x.cgFloat, y: self.origin.y.cgFloat)
            let size = CGSize(width: self.size.width.cgFloat, height: self.size.height.cgFloat)
            return CGRect(origin: origin, size: size)
        }
    }
#endif
