#if ReactantRuntime
import UIKit
#endif

//public func controlState<T: SupportedPropertyType>(name: String, type: T.Type) -> ControlStatePropertyDescription<T> {
//    return controlState(name: name, key: name, type: type)
//}
//
//public func controlState<T: SupportedPropertyType>(name: String, key: String, type: T.Type) -> ControlStatePropertyDescription<T> {
//    return ControlStatePropertyDescription(name: name, key: key)
//}

public struct ControlStateProperty<T: SupportedPropertyType>: Property {
    public let namespace: [PropertyContainer.Namespace]
    public let attributeName: String
    public let description: ControlStatePropertyDescription<T>
    public var value: T

    public func application(on target: String) -> String {
        let state = parseState(from: attributeName) as [ControlState]
        let stringState = state.map { "UIControlState.\($0.rawValue)" }.joined(separator: ", ")
        let namespacedTarget = namespace.resolvedSwiftName(target: target)
        return "\(namespacedTarget).set\(description.key.capitalizingFirstLetter())(\(value.generated), for: [\(stringState)])"
    }
    
    #if SanAndreas
    public func dematerialize() -> MagicAttribute {
        return MagicAttribute(name: attributeName, value: value.dematerialize())
    }
    #endif

    #if ReactantRuntime
    public func apply(on object: AnyObject) throws {
        let key = description.key
        let selector = Selector("set\(key.capitalizingFirstLetter()):forState:")
        
        let target = try resolveTarget(for: object)
        
        guard object.responds(to: selector) else {
            throw LiveUIError(message: "!! Object \(object) doesn't respond to \(selector) (property: \(self))")
        }
        guard let resolvedValue = value.runtimeValue else {
            throw LiveUIError(message: "!! Value `\(value)` couldn't be resolved in runtime for key `\(key)`")
        }
        let signature = object.method(for: selector)

        typealias setValueForControlStateIMP = @convention(c) (AnyObject, Selector, AnyObject, UIControlState) -> Void
        let method = unsafeBitCast(signature, to: setValueForControlStateIMP.self)
        method(object, selector, resolvedValue as AnyObject, parseState(from: attributeName).resolveUnion())
    }
    
    private func resolveTarget(for object: AnyObject) throws -> AnyObject {
        if namespace.isEmpty {
            return object
        } else {
            let keyPath = namespace.resolvedKeyPath
            guard let target = object.value(forKeyPath: keyPath) else {
                throw LiveUIError(message: "!! Object \(object) doesn't have keyPath \(keyPath) to resolve real target")
            }
            return target as AnyObject
        }
    }
    #endif

    private func parseState(from attributeName: String) -> [ControlState] {
        return attributeName.components(separatedBy: ".").dropFirst().flatMap(ControlState.init)
    }
}

public struct ControlStatePropertyDescription<T: SupportedPropertyType>: TypedPropertyDescription {
    public typealias ValueType = T
    
    public let namespace: [PropertyContainer.Namespace]
    public let name: String
    public let key: String

    public func matches(attributeName: String) -> Bool {
        let resolvedAttributeName = namespace.resolvedAttributeName(name: name)
        return attributeName == resolvedAttributeName || attributeName.hasPrefix("\(resolvedAttributeName).")
    }

    public func get(from properties: [String: Property], for state: [ControlState]) -> T? {
        let property = getProperty(from: properties, for: state)
        return property?.value
    }

    public func set(value: T, to properties: inout [String: Property], for state: [ControlState]) {
        var property = getProperty(from: properties, for: state) ?? makeProperty(with: name, value: value)
        property.value = value
        setProperty(property, to: &properties, for: state)
    }

    public func materialize(attributeName: String, value: String) throws -> Property {
        let materializedValue = try T.materialize(from: value)
        return makeProperty(with: attributeName, value: materializedValue)
    }

    private func getProperty(from dictionary: [String: Property], for state: [ControlState]) -> ControlStateProperty<T>? {
        return dictionary[dictionaryKey(for: state)] as? ControlStateProperty<T>
    }

    private func setProperty(_ property: Property, to dictionary: inout [String: Property], for state: [ControlState]) {
        dictionary[dictionaryKey(for: state)] = property
    }
    
    private func dictionaryKey(for state: [ControlState]) -> String {
        return namespace.resolvedAttributeName(name: "\(name).\(state.name)")
    }

    private func makeProperty(with attributeName: String, value: T) -> ControlStateProperty<T> {
        return ControlStateProperty(namespace: namespace, attributeName: attributeName, description: self, value: value)
    }
}
