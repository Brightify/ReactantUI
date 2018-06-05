//
//  Structure.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import Foundation



struct Parameter<T: AttributeSupportedPropertyType>: AttributeSupportedPropertyType {
    public let label: String
    public let value: T

    public init(label: String, value: T) {
        self.label = label
        self.value = value
    }

    func generate(context: SupportedPropertyTypeContext) -> String {
        return "\(label): \(value.generate(context: context.sibling(for: value)))"
    }

    static func materialize(from value: String) throws -> Parameter {
        let label = String(value.prefix(while: { $0 != ":" }))
        let materializedValue = try T.materialize(from: String(value.dropFirst(label.count + 1)))
        return Parameter(label: label, value: materializedValue)
    }

    func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return nil
    }

    // FIXME
    static var xsdType: XSDType { return .builtin(.integer) }
}

protocol StructurableProperty: AttributeSupportedPropertyType {
    static var structureName: String { get }
    var parameters: [AttributeSupportedPropertyType] { get }
    init(parameters: [AttributeSupportedPropertyType])
}



//extension StructurableProperty {
//    func generate(context: SupportedPropertyTypeContext) -> String {
//        let parameters = value.parameters.map { parameter -> String in
//            return parameter.generate(context: context)
//        }
//        return "\(T.structureName)(\(parameters))"
//    }
//
//    static func materialize(from value: String) throws -> Structure<T> {
//        // some checking whether the parameter labels are ok?
//        let structurableProperty = T.init(parameters: try value.components(separatedBy: "|").map { try T.materialize(from: $0) })
//        return Structure<T>(value: structurableProperty)
//    }
//
//    func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
//        return nil
//    }
//
//    // FIXME
//    static var xsdType: XSDType { return XSDType.builtin(.integer) }
//}

//struct Shadow: StructurableProperty {
//    public static let structureName = "NSShadow"
//    public let parameters: [AttributeSupportedPropertyType]
//
//    init(parameters: [AttributeSupportedPropertyType]) {
//        self.parameters = parameters
//    }
//}

struct Structure<T: StructurableProperty> {
    public private(set) var value: T

    public init(value: T) {
        self.value = value
    }
}

extension Structure: AttributeSupportedPropertyType {
    func generate(context: SupportedPropertyTypeContext) -> String {
        let parameters = value.parameters.map { parameter -> String in
            return parameter.generate(context: context)
        }
        return "\(T.structureName)(\(parameters))"
    }

    static func materialize<T: StructurableProperty>(from value: String) throws -> Structure<T> {
        // some checking whether the parameter labels are ok?
        let structurableProperty = T.init(parameters: try value.components(separatedBy: "|").map { try T.materialize(from: $0) })
        return Structure<T>(value: structurableProperty)
    }

    func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return nil
    }

    // FIXME
    static var xsdType: XSDType { return XSDType.builtin(.integer) }
}
