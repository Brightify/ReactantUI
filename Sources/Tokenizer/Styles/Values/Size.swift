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

    public var generated: String {
        return "CGSize(width: \(width.cgFloat), height: \(height.cgFloat))"
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
    return "\(width), \(height)"
    }
    #endif

    public static func materialize(from value: String) throws -> Size {
        let parts = value.components(separatedBy: ",").flatMap(Float.init)
        guard parts.count == 2 else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return Size(width: parts[0], height: parts[1])
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
