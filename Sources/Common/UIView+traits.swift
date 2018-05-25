//
//  UIView+traits.swift
//  ReactantUI
//
//  Created by Tadeáš Kříž on 04/05/2018.
//

import Foundation
import UIKit

public extension UIView {
    public var traits: UITraitHelper {
        return UITraitHelper(for: self)
    }
}

public struct UITraitHelper {
    public var horizontalSize: UIUserInterfaceSizeClass {
        return view.traitCollection.horizontalSizeClass
    }

    public var verticalSize: UIUserInterfaceSizeClass {
        return view.traitCollection.verticalSizeClass
    }

    public var isHorizontal: Bool {
        guard let window = UIApplication.shared.keyWindow else { return false }
        return window.bounds.width > window.bounds.height
    }

    public var isVertical: Bool {
        return !isHorizontal
    }

    private let view: UIView

    public init(for view: UIView) {
        self.view = view
    }

    public func size(horizontal sizeClass: UIUserInterfaceSizeClass) -> Bool {
        return view.traitCollection.containsTraits(in: UITraitCollection(horizontalSizeClass: sizeClass))
    }

    public func size(vertical sizeClass: UIUserInterfaceSizeClass) -> Bool {
        return view.traitCollection.containsTraits(in: UITraitCollection(verticalSizeClass: sizeClass))
    }

    public func device(_ deviceType: UIUserInterfaceIdiom) -> Bool {
        return UIDevice.current.userInterfaceIdiom == deviceType
    }

    public func orientation(_ orientation: UIDeviceOrientation) -> Bool {
        return UIDevice.current.orientation == orientation
    }

    public enum DimensionType {
        case width
        case height
    }

    public func viewRootSize(_ dimensionType: DimensionType) -> Float {
        switch dimensionType {
        case .width:
            return Float(getTopView().frame.width)
        case .height:
            return Float(getTopView().frame.height)
        }
    }

    private func getTopView() -> UIView {
        var supersuperview = view
        while let supererview = view.superview {
            supersuperview = supererview
        }

        return supersuperview
    }
}
