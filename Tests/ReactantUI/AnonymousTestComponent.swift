//
//  AnonymousTestComponent.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 14/06/2018.
//

import UIKit
import Reactant
import ReactantLiveUI

public class AnonymousTestComponent: UIView, Anonymous {
    fileprivate var _properties: [String: Any] = [:]
    fileprivate var _selectionStyle: UITableViewCellSelectionStyle = .default
    fileprivate var _focusStyle: UITableViewCellFocusStyle = .default

    public init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}

extension AnonymousTestComponent: RootView {
    public var edgesForExtendedLayout: UIRectEdge {
        return []
    }
}

extension AnonymousTestComponent: TableViewCell {
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
