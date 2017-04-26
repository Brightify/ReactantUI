//
//  Rect.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct Rect {
    let origin: Point
    let size: Size

    init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }

    init(x: Float, y: Float, width: Float, height: Float) {
        self.init(origin: Point(x: x, y: y), size: Size(width: width, height: height))
    }
}

#if ReactantRuntime

    extension Rect: Appliable {

        public var value: Any? {
            let origin = CGPoint(x: self.origin.x.cgFloat, y: self.origin.y.cgFloat)
            let size = CGSize(width: self.size.width.cgFloat, height: self.size.height.cgFloat)
            return CGRect(origin: origin, size: size)
        }
    }
#endif
