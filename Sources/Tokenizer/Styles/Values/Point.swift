//
//  Point.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct Point {
    let x: Float
    let y: Float
}

#if ReactantRuntime

    extension Point: Appliable {

        public var value: Any? {
            return CGPoint(x: x.cgFloat, y: y.cgFloat)
        }
    }
#endif
