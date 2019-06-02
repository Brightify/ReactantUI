//
//  UIControlEventObserver.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 01/06/2019.
//

import Foundation
import Hyperdrive

#if canImport(UIKit)
import UIKit

public final class ControlEventObserver: NSObject {
    private var associationKey: UInt8 = 0

    private weak var control: UIControl?
    private let events: UIControl.Event
    private let callback: ((UIControl) -> Void)?

    private let selector = #selector(ControlEventObserver.eventHandler(_:))

    public convenience init(control: UIControl, events: UIControl.Event, callback: @escaping () -> Void) {
        self.init(control: control, events: events, callback: { _ in callback() })
    }

    public init(control: UIControl, events: UIControl.Event, callback: @escaping (UIControl) -> Void) {
        self.control = control
        self.events = events
        self.callback = callback

        super.init()

//        let p = ActionPublisher<Bool>(publisher: { _ in })
//
//        p.publisher

        control.addTarget(self, action: selector, for: events)
    }

    @objc
    func eventHandler(_ sender: UIControl!) {
        guard let control = control else { return }
        callback?(control)
    }

    deinit {
        control?.removeTarget(self, action: selector, for: events)
    }

    public func retained(in object: NSObject) {
        associateObject(object, key: &associationKey, value: self, policy: .retain)
    }
}
#endif
