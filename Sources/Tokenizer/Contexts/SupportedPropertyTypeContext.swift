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

public struct SupportedPropertyTypeContext: DataContext {
    public let parentContext: DataContext
    public let value: SupportedPropertyType

    public init(parentContext: DataContext, value: SupportedPropertyType) {
        self.parentContext = parentContext
        self.value = value
    }
}

extension SupportedPropertyTypeContext: HasParentContext {
//    public var parentContext: PropertyContext {
//        return propertyContext
//    }
}

extension PropertyContext {
    public func child(for value: SupportedPropertyType) -> SupportedPropertyTypeContext {
        return SupportedPropertyTypeContext(parentContext: self, value: value)
    }
}

extension SupportedPropertyTypeContext {
    public func sibling(for value: SupportedPropertyType) -> SupportedPropertyTypeContext {
        return SupportedPropertyTypeContext(parentContext: self, value: value)
    }
}
