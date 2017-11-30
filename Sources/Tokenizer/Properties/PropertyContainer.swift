//
//  PropertyContainer.swift
//  ReactantUI
//
//  Created by Matous Hybl on 18/08/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

extension Array where Element == PropertyContainer.Namespace {
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
        let name: String
        let isOptional: Bool
    }
    
    public final class Configuration {
        public let namespace: [Namespace]
        public var properties: [PropertyDescription] = []
        
        public init(namespace: [Namespace]) {
            self.namespace = namespace
        }
        
        func assignable<T>(name: String, swiftName: String, key: String) -> AssignablePropertyDescription<T> {
            let property = AssignablePropertyDescription<T>(namespace: namespace, name: name, swiftName: swiftName, key: key)
            properties.append(property)
            return property
        }

        func value<T>(name: String) -> ValuePropertyDescription<T> {
            let property = ValuePropertyDescription<T>(namespace: namespace, name: name)
            properties.append(property)
            return property
        }
        
        func controlState<T>(name: String, key: String) -> ControlStatePropertyDescription<T> {
            let property = ControlStatePropertyDescription<T>(namespace: namespace, name: name, key: key)
            properties.append(property)
            return property
        }
        
        public func property<T>(name: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: name, key: name)
        }
        
        public func property<T>(name: String, swiftName: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: swiftName, key: name)
        }
        
        public func property<T>(name: String, key: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: name, key: key)
        }
        
        public func property<T>(name: String, swiftName: String, key: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: swiftName, key: key)
        }
        
        public func property<T>(name: String) -> ControlStatePropertyDescription<T> {
            return controlState(name: name, key: name)
        }
        
        public func property<T>(name: String, key: String) -> ControlStatePropertyDescription<T> {
            return controlState(name: name, key: key)
        }

        public func property<T>(name: String) -> ValuePropertyDescription<T> {
            return value(name: name)
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
