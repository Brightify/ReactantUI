//
//  EdgeInsets.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct EdgeInsets {
    let top: Float
    let left: Float
    let bottom: Float
    let right: Float
}

#if ReactantRuntime
import UIKit

extension EdgeInsets: Applicable {

    public var value: Any? {
        return UIEdgeInsetsMake(top.cgFloat, left.cgFloat, bottom.cgFloat, right.cgFloat)
    }
}
#endif
