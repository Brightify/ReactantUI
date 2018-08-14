//
//  Snapshotter.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 14/06/2018.
//

import UIKit

enum SnapshotError: Error {
    case noPointer(AnyObject)
    case noCgImage(UIImage)
    case noWindow(AnyObject)
    case noContext(AnyObject)
    case noImageInContext(AnyObject)
    case zeroWidth(AnyObject)
    case zeroHeight(AnyObject)

    var description: String {
        switch self {
        case .noPointer(let object):
            return "Unable to allocate memory for \(object)."
        case .noCgImage(let image):
            return "Provided UIImage \(image) has no CGImage value."
        case .noWindow:
            return "Unable to find a UIWindow to snapshot UIView in."
        case .noContext(let object):
            return "Could not generate context for \(object)."
        case .noImageInContext(let object):
            return "Could not get snapshot from image context for \(object)."
        case .zeroWidth(let object):
            return "Zero width for \(object)."
        case .zeroHeight(let object):
            return "Zero height for \(object)."
        }
    }
}

struct Snapshotter {
    static func takeSnapshot(of view: UIView) throws -> UIImage {
        if TestOptions.shouldUseDrawViewHierarchyInRect {
            return try imageFor(view: view)
        } else {
            return try imageFor(viewLayer: view)
        }
    }

    private static func imageFor(view: UIView) throws -> UIImage {
        let window = (view as? UIWindow) ?? view.window ?? UIApplication.shared.keyWindow

        if let window = window, view.window == nil && view != window {
            window.addSubview(view)

            defer { view.removeFromSuperview() }
        }

        view.layoutIfNeeded()
        let bounds = view.bounds
        guard bounds.width > 0 else { throw SnapshotError.zeroWidth(view) }
        guard bounds.height > 0 else { throw SnapshotError.zeroHeight(view) }

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)

        guard let snapshot = UIGraphicsGetImageFromCurrentImageContext() else { throw SnapshotError.noImageInContext(view) }
        return snapshot
    }

    private static func imageFor(viewLayer: UIView) throws -> UIImage {
        viewLayer.layoutIfNeeded()
        return try imageFor(layer: viewLayer.layer)
    }

    private static func imageFor(layer: CALayer) throws -> UIImage {
        let bounds = layer.bounds
        guard bounds.width > 0 else { throw SnapshotError.zeroWidth(layer) }
        guard bounds.height > 0 else { throw SnapshotError.zeroHeight(layer) }

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { throw SnapshotError.noContext(layer) }
        context.saveGState()
        layer.layoutIfNeeded()
        layer.render(in: context)
        context.restoreGState()

        guard let snapshot = UIGraphicsGetImageFromCurrentImageContext() else { throw SnapshotError.noImageInContext(layer) }
        return snapshot
    }
}
