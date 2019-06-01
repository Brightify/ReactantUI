//
//  Double+CGFloat.swift
//  Hyperdrive
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import CoreGraphics
import Foundation

public extension Double {
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
}
