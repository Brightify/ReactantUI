//
//  SupportedPropertyTypeContext.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 01/06/2018.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/**
 * Context connected to a property's type.
 */
public class SupportedPropertyTypeContext: DataContext, HasParentContext {
    public let parentContext: DataContext
    public let value: AnyPropertyValue

    public init(parentContext: DataContext, value: AnyPropertyValue) {
        self.parentContext = parentContext
        self.value = value
    }
}

extension PropertyContext {
    public func child(for value: SupportedPropertyType) -> SupportedPropertyTypeContext {
        return child(for: .value(value))
    }

    public func child<T>(for value: PropertyValue<T>) -> SupportedPropertyTypeContext {
        return child(for: value.typeErased())
    }

    public func child(for value: AnyPropertyValue) -> SupportedPropertyTypeContext {
        return SupportedPropertyTypeContext(parentContext: self, value: value)
    }
}

extension SupportedPropertyTypeContext {
    public func child(for value: SupportedPropertyType) -> SupportedPropertyTypeContext {
        return child(for: .value(value))
    }

    public func child<T>(for value: PropertyValue<T>) -> SupportedPropertyTypeContext {
        return child(for: value.typeErased())
    }

    public func child(for value: AnyPropertyValue) -> SupportedPropertyTypeContext {
        return SupportedPropertyTypeContext(parentContext: self, value: value)
    }
}
