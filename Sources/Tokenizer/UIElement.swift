//
//  UIElement.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if ReactantRuntime
import UIKit
#endif

public protocol UIElement: class, Assignable, MagicElementSerializable {
    var layout: Layout { get set }
    var properties: [Property] { get set }
    var toolingProperties: [String: Property] { get set }
    var styles: [String] { get set }

    static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }
    static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }

    // used for generating styles - does not care about children imports
    static var parentModuleImport: String { get }

    // used for generating views - resolves imports of subviews.
    var requiredImports: Set<String> { get }

    var initialization: String { get }

    #if ReactantRuntime
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
