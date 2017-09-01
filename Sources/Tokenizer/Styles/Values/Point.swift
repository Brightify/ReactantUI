//
//  Point.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct Point: SupportedPropertyType {
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

    public var generated: String {
        return "CGPoint(x: \(x.cgFloat), y: \(y.cgFloat))"
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
        return "\(x), \(y)"
    }
    #endif

    public static func materialize(from value: String) throws -> Point {
        let parts = value.components(separatedBy: ",").flatMap { Float($0.trimmingCharacters(in: CharacterSet.whitespaces)) }
        guard parts.count == 2 else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return Point(x: parts[0], y: parts[1])
    }
}

#if ReactantRuntime
    extension Point {

        public var runtimeValue: Any? {
            return CGPoint(x: x.cgFloat, y: y.cgFloat)
        }
    }
#endif
