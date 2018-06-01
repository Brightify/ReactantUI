//
//  Property.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if ReactantRuntime
import UIKit
#endif

public protocol Property {
    var name: String { get }
    
    var attributeName: String { get }
    
    var namespace: [PropertyContainer.Namespace] { get }
    
    func application(on target: String, context: ElementContext) -> String

    #if SanAndreas
    func dematerialize(context: ElementContext) -> XMLSerializableAttribute
    #endif
    
    #if ReactantRuntime
    func apply(on object: AnyObject, context: ElementContext) throws -> Void
    #endif
}

public protocol TypedProperty: Property {
    associatedtype ValueType: SupportedPropertyType

    var value: ValueType { get set }
}
