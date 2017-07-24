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

    public var generated: String {
        return "CGPoint(x: \(x.cgFloat), y: \(y.cgFloat))"
    }

    public static func materialize(from value: String) throws -> Point {
        let parts = value.components(separatedBy: ",").flatMap(Float.init)
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
