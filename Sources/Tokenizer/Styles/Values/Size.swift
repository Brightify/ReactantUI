//
//  Size.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct Size: SupportedPropertyType {
    public let width: Float
    public let height: Float
    
    public init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }
    
    public init(width: Double, height: Double) {
        self.width = Float(width)
        self.height = Float(height)
    }

    public var generated: String {
        return "CGSize(width: \(width.cgFloat), height: \(height.cgFloat))"
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
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
        return .builtin(.number)
    }
}

#if ReactantRuntime
    import UIKit

    extension Size {

        public var runtimeValue: Any? {
            return CGSize(width: width.cgFloat, height: height.cgFloat)
        }
    }
#endif
