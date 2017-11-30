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
    
    func application(on target: String) -> String

    #if SanAndreas
    func dematerialize() -> MagicAttribute
    #endif
    
    #if ReactantRuntime
    func apply(on object: AnyObject) throws -> Void
    #endif
}

public protocol TypedProperty: Property {
    associatedtype ValueType: SupportedPropertyType

    var value: ValueType { get set }
}
