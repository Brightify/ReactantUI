#if ReactantRuntime
import UIKit
#endif

public func assignable<T: SupportedPropertyType>(name: String, type: T.Type) -> AssignablePropertyDescription<T> {
    return assignable(name: name, key: name, type: type)
}

public func assignable<T: SupportedPropertyType>(name: String, key: String, type: T.Type) -> AssignablePropertyDescription<T> {
    return assignable(name: name, swiftName: name, key: key, type: type)
}

public func assignable<T: SupportedPropertyType>(name: String, swiftName: String, key: String, type: T.Type) -> AssignablePropertyDescription<T> {
    return AssignablePropertyDescription(name: name, swiftName: swiftName, key: key)
}

public struct AssignableProperty<T: SupportedPropertyType>: TypedProperty {

    public let attributeName: String
    public let description: AssignablePropertyDescription<T>
    public var value: T

    public func application(on target: String) -> String {
        return "\(target).\(description.swiftName) = \(value.generated)"
    }
    
    #if SanAndreas
    public func dematerialize() -> MagicAttribute {
        return MagicAttribute(name: attributeName, value: value.dematerialize())
    }
    #endif

    #if ReactantRuntime
    public func apply(on object: AnyObject) throws {
        NSLog("apply \(attributeName) \(value)")
        let key = description.key
        guard let resolvedValue = value.runtimeValue else {
            throw LiveUIError(message: "!! Value `\(value)` couldn't be resolved in runtime for key `\(key)`")
        }

        guard object.responds(to: Selector("set\(key.capitalizingFirstLetter()):")) else {
            NSLog("THE FUCK apply \(attributeName) \(value)")
            throw LiveUIError(message: "!! Object `\(object)` doesn't respond to selector `\(key)` to set value `\(value)`")
        }
        var mutableObject: AnyObject? = resolvedValue as AnyObject
        do {
            //            try object.validateValue(&mutableObject, forKey: key)
            object.setValue(mutableObject, forKey: key)
        } catch {
            throw LiveUIError(message: "!! Value `\(value)` isn't valid for key `\(key)` on object `\(object)")
        }
    }
    #endif
}

public struct AssignablePropertyDescription<T: SupportedPropertyType>: TypedPropertyDescription {
    public typealias ValueType = T

    public let name: String
    public let swiftName: String
    public let key: String

    public func get(from properties: [String: Property]) -> T? {
        let property = getProperty(from: properties)
        return property?.value
    }

    public func set(value: T, to properties: inout [String: Property]) {
        var property = getProperty(from: properties) ?? makeProperty(with: name, value: value)
        property.value = value
        setProperty(property, to: &properties)
    }

    public func materialize(attributeName: String, value: String) throws -> Property {
        let materializedValue = try T.materialize(from: value)
        return makeProperty(with: attributeName, value: materializedValue)
    }

    private func getProperty(from dictionary: [String: Property]) -> AssignableProperty<T>? {
        return dictionary[name] as? AssignableProperty<T>
    }

    private func setProperty(_ property: Property, to dictionary: inout [String: Property]) {
        dictionary[name] = property
    }

    private func makeProperty(with attributeName: String, value: T) -> AssignableProperty<T> {
        return AssignableProperty(attributeName: attributeName, description: self, value: value)
    }

//    func application(of property: Property, on target: String) -> String {
//        return "\(target).\(swiftName) = \(property.value.generated)"
//    }
//
//    #if ReactantRuntime
//    func apply(_ property: Property, on object: AnyObject) throws {
//        guard let resolvedValue = property.value.value else {
//            throw LiveUIError(message: "!! Value `\(property.value)` couldn't be resolved in runtime for key `\(key)`")
//        }
//
//        guard object.responds(to: Selector("set\(key.capitalizingFirstLetter()):")) else {
//            throw LiveUIError(message: "!! Object `\(object)` doesn't respond to selector `\(key)` to set value `\(property.value)`")
//        }
//        var mutableObject: AnyObject? = resolvedValue as AnyObject
//        do {
////            try object.validateValue(&mutableObject, forKey: key)
//            object.setValue(mutableObject, forKey: key)
//        } catch {
//            throw LiveUIError(message: "!! Value `\(property.value)` isn't valid for key `\(key)` on object `\(object)")
//        }
//    }
//    #endif
}
