//
//  PropertyContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

public struct PropertyContext: DataContext, HasParentContext {
    public let parentContext: DataContext
    public let property: Property

    public init(parentContext: DataContext, property: Property) {
        self.parentContext = parentContext
        self.property = property
    }
}
