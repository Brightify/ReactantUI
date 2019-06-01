//
//  PropertyContainer.swift
//  ReactantUI
//
//  Created by Matous Hybl on 18/08/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public extension Array where Element == PropertyContainer.Namespace {
    var resolvedKeyPath: String {
        return map { $0.name }.joined(separator: ".")
    }
    
    func resolvedAttributeName(name: String) -> String {
        return (map { $0.name } + [name]).joined(separator: ".")
    }
    
    func resolvedSwiftName(target: String) -> String {
        return ([target] + map { "\($0.name)\($0.isOptional ? "?" : "")" }).joined(separator: ".")
    }
}

public class PropertyContainer {
    public struct Namespace {
        public let name: String
        public let isOptional: Bool
    }
    
    public final class Configuration {
        public let namespace: [Namespace]
        public var properties: [PropertyDescription] = []
        
        public init(namespace: [Namespace]) {
            self.namespace = namespace
        }
        
        func assignable<T>(name: String, swiftName: String, key: String, defaultValue: T) -> AssignablePropertyDescription<T> {
            let property = AssignablePropertyDescription<T>(namespace: namespace, name: name, swiftName: swiftName, key: key, defaultValue: defaultValue)
            properties.append(property)
            return property
        }

        // TODO Remove with Swift 4.2
        func assignable<T>(name: String, defaultValue: T) -> ElementAssignablePropertyDescription<T> {
            let property = ElementAssignablePropertyDescription<T>(namespace: namespace, name: name, swiftName: name, key: name, defaultValue: defaultValue)
            properties.append(property)
            return property
        }

        func value<T>(name: String, defaultValue: T) -> ValuePropertyDescription<T> {
            let property = ValuePropertyDescription<T>(namespace: namespace, name: name, defaultValue: defaultValue)
            properties.append(property)
            return property
        }
        
        func controlState<T>(name: String, key: String, defaultValue: T) -> ControlStatePropertyDescription<T> {
            let property = ControlStatePropertyDescription<T>(namespace: namespace, name: name, key: key, defaultValue: defaultValue)
            properties.append(property)
            return property
        }

        // TODO Remove with Swift 4.2
        func controlState<T>(name: String, key: String, defaultValue: T) -> ElementControlStatePropertyDescription<T> {
            let property = ElementControlStatePropertyDescription<T>(namespace: namespace, name: name, key: key, defaultValue: defaultValue)
            properties.append(property)
            return property
        }
        
        public func property<T: HasDefaultValue>(name: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: name, key: name, defaultValue: T.defaultValue)
        }

        public func property<T>(name: String, defaultValue: T) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: name, key: name, defaultValue: defaultValue)
        }

        public func property<T: HasDefaultValue>(name: String, swiftName: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: swiftName, key: name, defaultValue: T.defaultValue)
        }

        public func property<T>(name: String, swiftName: String, defaultValue: T) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: swiftName, key: name, defaultValue: defaultValue)
        }
        
        public func property<T: HasDefaultValue>(name: String, key: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: name, key: key, defaultValue: T.defaultValue)
        }

        public func property<T>(name: String, key: String, defaultValue: T) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: name, key: key, defaultValue: defaultValue)
        }
        
        public func property<T: HasDefaultValue>(name: String, swiftName: String, key: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: swiftName, key: key, defaultValue: T.defaultValue)
        }

        public func property<T>(name: String, swiftName: String, key: String, defaultValue: T) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: swiftName, key: key, defaultValue: defaultValue)
        }

        public func property<T: HasDefaultValue>(name: String) -> ElementAssignablePropertyDescription<T> {
            return assignable(name: name, defaultValue: T.defaultValue)
        }

        public func property<T>(name: String, defaultValue: T) -> ElementAssignablePropertyDescription<T> {
            return assignable(name: name, defaultValue: defaultValue)
        }
        
        public func property<T: HasDefaultValue>(name: String) -> ControlStatePropertyDescription<T> {
            return controlState(name: name, key: name, defaultValue: T.defaultValue)
        }

        public func property<T>(name: String, defaultValue: T) -> ControlStatePropertyDescription<T> {
            return controlState(name: name, key: name, defaultValue: defaultValue)
        }

        public func property<T: HasDefaultValue>(name: String) -> ElementControlStatePropertyDescription<T> {
            return controlState(name: name, key: name, defaultValue: T.defaultValue)
        }

        public func property<T>(name: String, defaultValue: T) -> ElementControlStatePropertyDescription<T> {
            return controlState(name: name, key: name, defaultValue: defaultValue)
        }
        
        public func property<T: HasDefaultValue>(name: String, key: String) -> ControlStatePropertyDescription<T> {
            return controlState(name: name, key: key, defaultValue: T.defaultValue)
        }

        public func property<T>(name: String, key: String, defaultValue: T) -> ControlStatePropertyDescription<T> {
            return controlState(name: name, key: key, defaultValue: defaultValue)
        }

        public func property<T: HasDefaultValue>(name: String) -> ValuePropertyDescription<T> {
            return value(name: name, defaultValue: T.defaultValue)
        }

        public func property<T>(name: String, defaultValue: T) -> ValuePropertyDescription<T> {
            return value(name: name, defaultValue: defaultValue)
        }

        public func property<T: HasDefaultValue>(name: String) -> MultipleAttributeAssignablePropertyDescription<T> {
            let property = MultipleAttributeAssignablePropertyDescription<T>(namespace: namespace, name: name, swiftName: name, key: name, defaultValue: T.defaultValue)
            properties.append(property)
            return property
        }

        public func property<T>(name: String, defaultValue: T) -> MultipleAttributeAssignablePropertyDescription<T> {
            let property = MultipleAttributeAssignablePropertyDescription<T>(namespace: namespace, name: name, swiftName: name, key: name, defaultValue: defaultValue)
            properties.append(property)
            return property
        }
        
        public func namespaced<T: PropertyContainer>(in namespace: String, optional: Bool = false, _ type: T.Type) -> T {
            let configuration = Configuration(namespace: self.namespace + [Namespace(name: namespace, isOptional: optional)])
            let container = T.init(configuration: configuration)
            properties.append(contentsOf: container.allProperties)
            return container
        }
    }
    
    let namespace: [Namespace]
    let allProperties: [PropertyDescription]
    
    public required init(configuration: Configuration) {
        self.namespace = configuration.namespace
        self.allProperties = configuration.properties
    }
}
