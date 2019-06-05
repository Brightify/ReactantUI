//
//  UIContainer.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
    import UIKit
#endif

/**
 * Basic container view protocol. If your UI element is capable of containing children, it should conform to this.
 */
public protocol UIContainer {
    var children: [UIElement] { get set }

    var providedActions: [(element: UIElementBase, actions: [HyperViewAction])] { get }

    var addSubviewMethod: String { get }

    func findChild(byId id: String) -> UIElement?

    #if canImport(UIKit)
    func add(subview: UIView, toInstanceOfSelf: UIView)
    #endif
}

public extension UIContainer {
    var allChildren: [UIElement] {
        return children.flatMap { child -> [UIElement] in
            if let childContainer = child as? UIContainer {
                return [child] + childContainer.allChildren
            } else {
                return [child]
            }
        }
    }

    func findChild(byId id: String) -> UIElement? {
        for child in children {
            if child.id.description == id {
                return child
            }

            if let childContainer = child as? UIContainer, let foundView = childContainer.findChild(byId: id) {
                return foundView
            }
        }

        return nil
    }
}

public extension UIContainer where Self: UIElementBase {
    #warning("TODO: Merge property names?")
    var providedActions: [(element: UIElementBase, actions: [HyperViewAction])] {
        return [(element: self, actions: handledActions)] + children.flatMap { child -> [(element: UIElementBase, actions: [HyperViewAction])] in
            if let childContainer = child as? UIContainer {
                return childContainer.providedActions
            } else if !child.handledActions.isEmpty {
                return [(element: child, actions: child.handledActions)]
            } else {
                return []
            }
        }
    }
}
