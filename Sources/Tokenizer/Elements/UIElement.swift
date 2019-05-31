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

import SwiftCodeGen

public struct HyperViewAction {
    public var name: String
    public var eventName: String
    public var parameters: [Parameter]

    public enum Parameter {
        case constant(type: String, value: String)
        case stateVariable(name: String)
        case reference(targetId: String, property: String?)
    }

    public init(name: String, eventName: String, parameters: [Parameter]) {
        self.name = name
        self.eventName = eventName
        self.parameters = parameters
    }

    #warning("TODO Properly parse actions")
    public init?(attribute: XMLAttribute) throws {
        guard attribute.name.starts(with: "action:") else { return nil }

        eventName = String(attribute.name.dropFirst("action:".count))

        name = attribute.text
        parameters = []
    }
}

/**
 * The most basic UI element protocol that every UI element should conform to.
 * UI elements usually conform to this protocol through `UIElement` or `View`.
 * Allows for more customization than conforming to `UIElement` directly.
 */
public protocol UIElementBase {
    var properties: [Property] { get set }
    var toolingProperties: [String: Property] { get set }
    var handledActions: [HyperViewAction] { get set }

    // used for generating styles - does not care about children imports
    static var parentModuleImport: String { get }

    // used for generating views - resolves imports of subviews.
    var requiredImports: Set<String> { get }
}

/**
 * Contains the interface to a real UI element (layout, styling).
 * Conforming to this protocol is sufficient on its own when creating a UI element.
 */
public protocol UIElement: AnyObject, UIElementBase, XMLElementSerializable {
    var field: String? { get }
    var layout: Layout { get set }
    var styles: [StyleName] { get set }

    static var defaultContentCompression: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }
    static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) { get }

    static func runtimeType() throws -> String

    func initialization(describeInto pipe: DescriptionPipe) throws

    #if canImport(UIKit)
    func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView
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
