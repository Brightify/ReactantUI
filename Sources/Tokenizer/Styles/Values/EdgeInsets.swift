//
//  EdgeInsets.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct EdgeInsets: SupportedPropertyType {
    let top: Float
    let left: Float
    let bottom: Float
    let right: Float

    public var generated: String {
        return "UIEdgeInsetsMake(\(top.cgFloat), \(left.cgFloat), \(bottom.cgFloat), \(right.cgFloat))"
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
        return "\(top), \(left), \(bottom), \(right)"
    }
    #endif

    public static func materialize(from value: String) throws -> EdgeInsets {
        let parts = value.components(separatedBy: ",").flatMap(Float.init)
        guard parts.count == 4 || parts.count == 2 else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        if parts.count == 4 {
            return EdgeInsets(top: parts[0], left: parts[1], bottom: parts[2], right: parts[3])
        }
        return EdgeInsets(top: parts[1], left: parts[0], bottom: parts[1], right: parts[0])
    }
}

#if ReactantRuntime
import UIKit

extension EdgeInsets {

    public var runtimeValue: Any? {
        return UIEdgeInsetsMake(top.cgFloat, left.cgFloat, bottom.cgFloat, right.cgFloat)
    }
}
#endif
