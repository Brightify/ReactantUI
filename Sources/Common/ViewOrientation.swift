//
//  ViewOrientation.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 07/06/2018.
//

import Foundation

public enum ViewOrientation {
    case landscape
    case portrait

    public var description: String {
        switch self {
        case .landscape:
            return "landscape"
        case .portrait:
            return "portrait"
        }
    }
}

extension ViewOrientation {
    public init(width: Float, height: Float) {
        self = width > height ? .landscape : .portrait
    }
}

#if canImport(CoreGraphics)
import CoreGraphics

extension ViewOrientation {
    public init(size: CGSize) {
        self.init(width: Float(size.width), height: Float(size.height))
    }
}
#endif
