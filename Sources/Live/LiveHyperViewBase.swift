//
//  LiveHyperViewBase.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 07/06/2019.
//

import UIKit
import Hyperdrive

public class LiveKeyPath {
    private let getValue: () -> Any?
    private let setValue: (Any?) throws -> Void

    public init<Object: AnyObject, T>(object: Object, keyPath: ReferenceWritableKeyPath<Object, T>) {
        getValue = {
            object[keyPath: keyPath]
        }
        setValue = { anyValue in
            guard let value = anyValue as? T else {
                throw LiveUIError(message: "Value \(anyValue) is not \(T.self) for object \(object)!")
            }
            object[keyPath: keyPath] = value
        }
    }

    // This is required because of https://github.com/apple/swift-evolution/blob/master/proposals/0140-bridge-optional-to-nsnull.md
    // If we don't do this (the as Any? in getter), the value is replaced by `NSNull` and that crashes when used.
    public init<Object: AnyObject, T>(object: Object, keyPath: ReferenceWritableKeyPath<Object, T?>) {
        getValue = {
            object[keyPath: keyPath] as Any?
        }
        setValue = { anyValue in
            // This is required to check if the nil is a correct type T
            if anyValue is T? && (anyValue as? T?) == nil {
                object[keyPath: keyPath] = nil
            } else if let value = anyValue as? T? {
                object[keyPath: keyPath] = value
            } else {
                throw LiveUIError(message: "Value \(anyValue) is not \(Optional<T>.self) for object \(object)!")
            }
        }
    }

    public init(getValue: @escaping () -> Any?, setValue: @escaping (Any?) throws -> Void) {
        self.getValue = getValue
        self.setValue = setValue
    }

    public func get() -> Any? {
        return getValue()
    }

    public func set(value: Any) throws {
        try setValue(value)
    }
    
}

open class LiveHyperViewBase: HyperViewBase {
    internal let xmlPath: String
    internal let typeName: String
    internal let worker: ReactantLiveUIWorker

    public init(worker: ReactantLiveUIWorker, typeName: String, xmlPath: String) {
        self.typeName = typeName
        self.xmlPath = xmlPath
        self.worker = worker

        super.init()

        worker.register(self, setConstraint: { name, constraint in
            return false
        })
    }

    open func stateProperty(named name: String) -> LiveKeyPath? {
        return nil
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        worker.reapply(self)
    }

    deinit {
        worker.unregister(self)
    }
}

public extension HyperView where Self: LiveHyperViewBase {
    func live<T>(keyPath: ReferenceWritableKeyPath<State, T>) -> LiveKeyPath {
        return LiveKeyPath(object: state, keyPath: keyPath)
    }

    func live<T>(keyPath: ReferenceWritableKeyPath<State, T?>) -> LiveKeyPath {
        return LiveKeyPath(object: state, keyPath: keyPath)
    }
}
