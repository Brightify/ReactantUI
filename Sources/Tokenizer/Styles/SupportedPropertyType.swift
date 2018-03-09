//
//  SupportedPropertyType.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public protocol SupportedPropertyType {
    var generated: String { get }

    #if SanAndreas
    func dematerialize() -> String
    #endif

    #if ReactantRuntime
    var runtimeValue: Any? { get }
    #endif

    static var xsdType: XSDType { get }

    static func materialize(from value: String) throws -> Self
}

public enum XSDType {
    case builtin(BuiltinXSDType)
    case enumeration(EnumerationXSDType)
    case union(UnionXSDType)
    case pattern(PatternXSDType)
}

public struct EnumerationXSDType {
    public let name: String
    public let base: BuiltinXSDType
    public let values: Set<String>
}

public struct UnionXSDType {
    public let name: String
    public let memberTypes: [XSDType]
}

public enum BuiltinXSDType: String {
    case string
    case number
    case boolean
    case token

    var xsdName: String {
        return "xs:".appending(rawValue)
    }
}

public struct PatternXSDType {
    public let name: String
    public let base: BuiltinXSDType
    public let value: String
}

