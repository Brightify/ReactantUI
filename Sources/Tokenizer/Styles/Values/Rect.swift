//
//  Rect.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct Rect: SupportedPropertyType {
    public let origin: Point
    public let size: Size

    public var generated: String {
        return "CGRect(origin: CGPoint(x: \(origin.x.cgFloat), y: \(origin.y.cgFloat)), size: CGSize(width: \(size.width.cgFloat), height: \(size.height.cgFloat)))"
    }

    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
        return "\(origin.x), \(origin.y), \(size.width), \(size.height)"
    }
    #endif

    public init(x: Float, y: Float, width: Float, height: Float) {
        self.init(origin: Point(x: x, y: y), size: Size(width: width, height: height))
    }

    public static func materialize(from value: String) throws -> Rect {
        let parts = value.components(separatedBy: ",").flatMap { Float($0.trimmingCharacters(in: CharacterSet.whitespaces)) }
        guard parts.count == 4 else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return Rect(x: parts[0], y: parts[1], width: parts[2], height: parts[3])
    }
}

#if ReactantRuntime

    extension Rect {
        public var runtimeValue: Any? {
            let origin = CGPoint(x: self.origin.x.cgFloat, y: self.origin.y.cgFloat)
            let size = CGSize(width: self.size.width.cgFloat, height: self.size.height.cgFloat)
            return CGRect(origin: origin, size: size)
        }
    }
#endif
