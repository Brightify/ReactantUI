//
//  AnonymousComponent.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import Reactant

internal typealias AnonymousComponent = AnonymousLiveComponent

public protocol Anonymous {}

public class AnonymousLiveComponent: ViewBase<Void, Void>, Anonymous {
    fileprivate let _typeName: String
    fileprivate let _xmlPath: String
    fileprivate var _properties: [String: Any] = [:]
    fileprivate var _selectionStyle: UITableViewCellSelectionStyle = .default
    fileprivate var _focusStyle: UITableViewCellFocusStyle = .default

    public init(typeName: String, xmlPath: String) {
        _xmlPath = xmlPath
        _typeName = typeName
        super.init()
    }

    public override func conforms(to aProtocol: Protocol) -> Bool {
        return super.conforms(to: aProtocol)
    }

    public override func value(forUndefinedKey key: String) -> Any? {
        return _properties[key]
    }

    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        _properties[key] = value
    }

    public override var description: String {
        return "AnonymousComponent: \(_typeName)"
    }
}

extension AnonymousComponent: ReactantUI {
    var rui: AnonymousComponent.RUIContainer {
        return Reactant.associatedObject(self, key: &AnonymousComponent.RUIContainer.associatedObjectKey) {
            return AnonymousComponent.RUIContainer(target: self)
        }
    }

    public var __rui: Reactant.ReactantUIContainer {
        return rui
    }

    final class RUIContainer: Reactant.ReactantUIContainer {
        fileprivate static var associatedObjectKey = 0 as UInt8

        let xmlPath: String

        let typeName: String

        private weak var target: AnonymousComponent?

        fileprivate init(target: AnonymousComponent) {
            self.target = target
            self.xmlPath = target._xmlPath
            self.typeName = target._typeName
        }

        func setupReactantUI() {
            guard let target = self.target else { /* FIXME Should we fatalError here? */ return }
            ReactantLiveUIManager.shared.register(target, setConstraint: { _, _ in true })
        }

        static func destroyReactantUI(target: UIView) {
            guard let knownTarget = target as? AnonymousComponent else { /* FIXME Should we fatalError here? */ return }
            ReactantLiveUIManager.shared.unregister(knownTarget)
        }
    }
}

extension AnonymousComponent: RootView {
    public var edgesForExtendedLayout: UIRectEdge {
        return ReactantLiveUIManager.shared.extendedEdges(of: self)
    }
}

extension AnonymousComponent: TableViewCell {
    public var selectionStyle: UITableViewCellSelectionStyle {
        get {
            return _selectionStyle
        }
        set {
            _selectionStyle = newValue
        }
    }

    public var focusStyle: UITableViewCellFocusStyle {
        get {
            return _focusStyle
        }
        set {
            _focusStyle = newValue
        }
    }
}
