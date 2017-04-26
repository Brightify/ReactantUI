//
//  Size.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct Size {
    let width: Float
    let height: Float
}

#if ReactantRuntime
    import UIKit

    extension Size: Appliable {

        public var value: Any? {
            return CGSize(width: width.cgFloat, height: height.cgFloat)
        }
    }
#endif
