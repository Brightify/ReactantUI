//
//  UITraitHelper.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 07/06/2018.
//

#if canImport(UIKit)
import Foundation
import UIKit

public class UITraitHelper {
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
    private lazy var rootView: UIView = getRootView()
    private var rootViewOrientation: ViewOrientation {
        return ViewOrientation(size: rootView.frame.size)
    }

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

    public func orientation(_ orientation: ViewOrientation) -> Bool {
        return rootViewOrientation == orientation
    }

    public enum DimensionType {
        case width
        case height
    }

    public func viewRootSize(_ dimensionType: DimensionType) -> Float {
        switch dimensionType {
        case .width:
            return Float(rootView.frame.width)
        case .height:
            return Float(rootView.frame.height)
        }
    }

    private func getRootView() -> UIView {
        var rootView = view
        while let superview = rootView.superview {
            rootView = superview
        }

        return rootView
    }
}
#endif

