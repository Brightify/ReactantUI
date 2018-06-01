//
//  SupportedPropertyTypeContext.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 01/06/2018.
//

import Foundation

public struct SupportedPropertyTypeContext: DataContext {
    public let propertyContext: PropertyContext
    public let value: SupportedPropertyType

    public init(propertyContext: PropertyContext, value: SupportedPropertyType) {
        self.propertyContext = propertyContext
        self.value = value
    }
}
