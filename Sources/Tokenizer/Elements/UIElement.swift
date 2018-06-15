//
//  UIElement.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public protocol UIElementBase {
    var properties: [Property] { get set }
    var toolingProperties: [String: Property] { get set }

    // used for generating styles - does not care about children imports
    static var parentModuleImport: String { get }

    // used for generating views - resolves imports of subviews.
    var requiredImports: Set<String> { get }
}

public protocol UIElement: AnyObject, UIElementBase, XMLElementSerializable {
    var field: String? { get }
    var layout: Layout { get set }
    var styles: [StyleName] { get set }

    static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }
    static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }

    func initialization() throws -> String

    #if canImport(UIKit)
    func initialize() throws -> UIView
    #endif
}

extension UIElement {
    public static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (ConstraintPriority.high, ConstraintPriority.high)
    }
    public static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (ConstraintPriority.low, ConstraintPriority.low)
    }
}
