//
//  EnumPropertyType.swift
//  ReactantUIGenerator
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

public protocol EnumPropertyType: RawRepresentable, SupportedPropertyType {
    static var enumName: String { get }
    static var allValues: [Self] { get }
}

extension EnumPropertyType where Self.RawValue == String {
    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "\(Self.enumName).\(rawValue)"
    }

    public static var xsdType: XSDType {
        let values = Set(Self.allValues.map { $0.rawValue })
        return .enumeration(EnumerationXSDType(name: Self.enumName, base: .string, values: values))
    }
}

extension EnumPropertyType {
    public static var runtimeType: String {
        return enumName
    }
}

extension SupportedPropertyType where Self: RawRepresentable, Self.RawValue == String {
    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return rawValue
    }
    #endif

    public static func materialize(from value: String) throws -> Self {
        guard let materialized = Self(rawValue: value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }
}
