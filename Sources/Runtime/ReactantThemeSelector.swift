//
//  ReactantThemeSelector.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 6/20/18.
//

import Foundation

public protocol ReactantThemeDefinition {
    var name: String { get }
}

public extension ReactantThemeDefinition where Self: RawRepresentable, Self.RawValue == String {
    public var name: String {
        return rawValue
    }
}

public class ReactantThemeSelector<THEME: ReactantThemeDefinition> where THEME: Equatable {
    public struct ListenerToken: Hashable, Equatable {
        private let identifier: ObjectIdentifier
        private let cancelation: () -> Void

        fileprivate init(identifier: ObjectIdentifier, cancel: @escaping () -> Void) {
            self.identifier = identifier
            self.cancelation = cancel
        }

        public func cancel() {
            cancelation()
        }

        public var hashValue: Int {
            return identifier.hashValue
        }

        public static func ==(lhs: ListenerToken, rhs: ListenerToken) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }

    private var listeners: [ObjectIdentifier: (THEME) -> Void] = [:]
    public private(set) var currentTheme: THEME {
        didSet {
            notifyListeners()
        }
    }

    public init(defaultTheme: THEME) {
        currentTheme = defaultTheme
    }

    public func select(theme: THEME) {
        guard theme != currentTheme else { return }
        currentTheme = theme
    }

    public func reapplyCurrentTheme() {
        notifyListeners()
    }

    @discardableResult
    public func register(target: AnyObject, listener: @escaping (THEME) -> Void) -> ListenerToken {
        // Make sure the listener is called with the current theme before exiting this function
        defer { listener(currentTheme) }

        // We keep the last listener registered for an object.
        let identifier = ObjectIdentifier(target)

        listeners[identifier] = listener

        return ListenerToken(identifier: identifier, cancel: { [weak self] in
            // TODO Do we want to crash if cancellation has been called multiple times?
            self?.unregister(identifier: identifier)
        })
    }

    public func unregister(target: AnyObject) {
        let identifier = ObjectIdentifier(target)
        unregister(identifier: identifier)
    }

    private func unregister(identifier: ObjectIdentifier) {
        listeners[identifier] = nil
    }

    private func notifyListeners() {
        let theme = currentTheme
        listeners.values.forEach { $0(theme) }
    }
}
