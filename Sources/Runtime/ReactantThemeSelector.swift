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
    public typealias Listener = (THEME) -> Void
    internal enum ListenerKey: Hashable {
        case object(ObjectIdentifier)
        case uuid(UUID)
    }
    public struct ListenerToken: Hashable, Equatable {
        private let key: ListenerKey
        private let cancelation: () -> Void

        internal init(key: ListenerKey, cancel: @escaping () -> Void) {
            self.key = key
            self.cancelation = cancel
        }

        public func cancel() {
            cancelation()
        }

        public var hashValue: Int {
            return key.hashValue
        }

        public static func ==(lhs: ListenerToken, rhs: ListenerToken) -> Bool {
            return lhs.key == rhs.key
        }
    }

    private var listeners: [ListenerKey: (THEME) -> Void] = [:]
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

    /**
     *  Creates a new registration bound to the target passed.
     *  NOTE: Only one listener can be registered for a single object instance.
     */
    @discardableResult
    public func register(target: AnyObject, listener: @escaping Listener) -> ListenerToken {
        let key = ListenerKey.object(ObjectIdentifier(target))
        return register(key: key, listener: listener)
    }

    /// Creates a new registration
    public func register(listener: @escaping Listener) -> ListenerToken {
        let key = ListenerKey.uuid(UUID())
        return register(key: key, listener: listener)
    }

    private func register(key: ListenerKey, listener: @escaping Listener) -> ListenerToken {
        // Make sure the listener is called with the current theme before exiting this function
        defer { listener(currentTheme) }

        listeners[key] = listener

        return ListenerToken(key: key, cancel: { [weak self] in
            // TODO Do we want to crash if cancellation has been called multiple times?
            self?.unregister(key: key)
        })
    }

    public func unregister(target: AnyObject) {
        let key = ListenerKey.object(ObjectIdentifier(target))
        unregister(key: key)
    }

    private func unregister(key: ListenerKey) {
        listeners[key] = nil
    }

    private func notifyListeners() {
        let theme = currentTheme
        listeners.values.forEach { $0(theme) }
    }
}
