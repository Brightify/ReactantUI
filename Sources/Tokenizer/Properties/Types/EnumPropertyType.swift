//
//  EnumPropertyType.swift
//  ReactantUIGenerator
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

public protocol EnumPropertyType: RawRepresentable, SupportedPropertyType, CaseIterable {
    static var enumName: String { get }
}

extension EnumPropertyType where Self.RawValue == String {
    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .constant("\(Self.enumName).\(rawValue)")
    }
    #endif

    public static var xsdType: XSDType {
        let values = Set(Self.allCases.map { $0.rawValue })
        return .enumeration(EnumerationXSDType(name: Self.enumName, base: .string, values: values))
    }
}

extension EnumPropertyType {
    public static func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        #warning("TODO: We should let the children decide the module here:")
        return RuntimeType(name: enumName)
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
