//
//  SPLIT.SwiftGenerating.swift
//  Generator
//
//  Created by Matyáš Kříž on 30/05/2019.
//

import Foundation

public protocol HasAttributes {
    var attributes: Attributes { get set }
}

public protocol HasAccessibility {
    var accessibility: Accessibility { get set }
}

public protocol HasModifiers {
    var modifiers: DeclarationModifiers { get set }
}

public struct Attributes: ExpressibleByArrayLiteral {
    private let attributes: [String]

    public init(arrayLiteral elements: String...) {
        self.attributes = elements
    }

    public init(_ attributes: [String] = []) {
        self.attributes = attributes
    }

    public func describe(into pipe: DescriptionPipe) {
        pipe.lines(attributes)
    }
}

public enum Accessibility: String, ExpressibleByStringLiteral {
    case `internal`
    case `public`
    case `private`
    case `fileprivate`
    case `open`

    public init(stringLiteral value: String) {
        switch value {
        case Accessibility.internal.rawValue:
            self = .internal
        case Accessibility.public.rawValue:
            self = .public
        case Accessibility.private.rawValue:
            self = .private
        case Accessibility.fileprivate.rawValue:
            self = .fileprivate
        case Accessibility.open.rawValue:
            self = .open
        default:
            print("Warning: Accessibility '\(value)' cannot be instantiated. Using `internal`.")
            self = .internal
        }
    }

    public var description: String {
        switch self {
        case .internal:
            return ""
        default:
            return self.rawValue
        }
    }
}

public struct DeclarationModifiers: OptionSet {
    public let rawValue: Int

    public static let convenience = DeclarationModifiers(rawValue: 1 << 0)
    public static let dynamic = DeclarationModifiers(rawValue: 1 << 1)
    public static let final = DeclarationModifiers(rawValue: 1 << 2)
    public static let infix = DeclarationModifiers(rawValue: 1 << 3)
    public static let lazy = DeclarationModifiers(rawValue: 1 << 4)
    public static let optional = DeclarationModifiers(rawValue: 1 << 5)
    public static let override = DeclarationModifiers(rawValue: 1 << 6)
    public static let postfix = DeclarationModifiers(rawValue: 1 << 7)
    public static let prefix = DeclarationModifiers(rawValue: 1 << 8)
    public static let required = DeclarationModifiers(rawValue: 1 << 9)
    public static let `static` = DeclarationModifiers(rawValue: 1 << 10)
    public static let unowned = DeclarationModifiers(rawValue: 1 << 11)
    public static let weak = DeclarationModifiers(rawValue: 1 << 12)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    private static let allValuesWithDescriptions: [(modifier: DeclarationModifiers, description: String)] = [
        (.convenience, "convenience"),
        (.dynamic, "dynamic"),
        (.final, "final"),
        (.infix, "infix"),
        (.lazy, "lazy"),
        (.optional, "optional"),
        (.override, "override"),
        (.postfix, "postfix"),
        (.prefix, "prefix"),
        (.required, "required"),
        (.static, "static"),
        (.unowned, "unowned"),
        (.weak, "weak"),
    ]

    public var description: String {
        return DeclarationModifiers.allValuesWithDescriptions
            .filter { contains($0.modifier) }
            .map { $0.description }
            .joined(separator: " ")
    }
}

public extension Optional {
    func format(into format: (Wrapped) -> String, defaultValue: String = "") -> String {
        return map { format($0) } ?? defaultValue
    }
}

public protocol Describable {
    func describe(into pipe: DescriptionPipe)
}

extension String: Describable {
    public func describe(into pipe: DescriptionPipe) {
        pipe.line(self)
    }
}

extension Array: Describable where Element == Describable {
    public func describe(into pipe: DescriptionPipe) {
        forEach {
            $0.describe(into: pipe)
        }
    }
}

public class DescriptionPipe {
    public enum Encapsulation {
        case none
        case parentheses
        case brackets
        case braces
        case custom(open: String, close: String)

        var open: String {
            switch self {
            case .none:
                return ""
            case .parentheses:
                return "("
            case .brackets:
                return "["
            case .braces:
                return "{"
            case .custom(let open, _):
                return open
            }
        }

        var close: String {
            switch self {
            case .none:
                return ""
            case .parentheses:
                return ")"
            case .brackets:
                return "]"
            case .braces:
                return "}"
            case .custom(_, let close):
                return close
            }
        }
    }

    public private(set) var result: [String] = [""]
    private var indentationLevel = 0
    private var lastLine: String {
        get {
            return result[result.endIndex - 1]
        }
        set {
            result[result.endIndex - 1] = newValue
        }
    }

    public init() {

    }

    @discardableResult
    public func block(
        line lineContent: String? = nil,
        encapsulateIn encapsulation: Encapsulation = .braces,
        header: String? = nil,
        descriptionBlock: () throws -> Void
    ) rethrows -> DescriptionPipe {
        lineEnd("\(lineContent.format(into: { "\($0) " }))\(encapsulation.open)\(header.format(into: { " \($0) in" }))")
        defer { line("\(encapsulation.close)") }
        try indented(descriptionBlock: descriptionBlock)

        return self
    }

    @discardableResult
    public func indented(descriptionBlock: () throws -> Void) rethrows -> DescriptionPipe {
        indentationLevel += 1
        defer {
            endOfLineIfNeeded()
            indentationLevel -= 1
        }
        try descriptionBlock()
        return self
    }

    private func endOfLineIfNeeded() {
        if lastLine != "" {
            result.append("")
        }
    }

    @discardableResult
    public func lineEnd(_ lineEndString: String = "") -> DescriptionPipe {
        string(lineEndString)
        result.append("")
        return self
    }

    @discardableResult
    public func string(_ string: String) -> DescriptionPipe {
        if lastLine == "" {
            lastLine = String(repeating: "\t", count: indentationLevel)
        }

        lastLine += string
        return self
    }

    @discardableResult
    public func line(_ contents: String = "") -> DescriptionPipe {
        if lastLine != "" {
            result.append("")
        }
        string(contents)
        result.append("")
        return self
    }

    @discardableResult
    public func line(times: Int) -> DescriptionPipe {
        let extraLines = lastLine == "" ? 0 : 1
        result.append(contentsOf: Array(repeating: "", count: times + extraLines))
        return self
    }

    @discardableResult
    public func lines(_ lines: String...) -> DescriptionPipe {
        self.lines(lines)
        return self
    }

    @discardableResult
    public func lines(_ lines: [String]) -> DescriptionPipe {
        let linesToAppend: [String]
        if lines.last == "" {
            linesToAppend = lines.dropLast()
        } else {
            linesToAppend = lines
        }
        linesToAppend.forEach { line($0) }
        return self
    }

    @discardableResult
    public func spaced(linePadding: Int = 1, describables: Describable...) -> DescriptionPipe {
        spaced(linePadding: linePadding, describables: describables)
        return self
    }

    @discardableResult
    public func spaced(linePadding: Int = 1, describables: [Describable]) -> DescriptionPipe {
        for (index, describable) in describables.enumerated() {
            describable.describe(into: self)
            if index != describables.endIndex - 1 {
                line(times: linePadding)
            }
        }
        return self
    }

    @discardableResult
    public func spaced(linePadding: Int = 1, describables: [(linePadding: Int, describables: [Describable])]) -> DescriptionPipe {
        return spaced(linePadding: linePadding, blocks: describables.map { padding, describables in
            { self.spaced(linePadding: padding, describables: describables) }
        })
    }

    @discardableResult
    public func spaced(linePadding: Int = 1, blocks: (() -> Void)...) -> DescriptionPipe {
        return spaced(linePadding: linePadding, blocks: blocks)
    }
    

    @discardableResult
    public func spaced(linePadding: Int = 1, blocks: [() -> Void]) -> DescriptionPipe {
        for (index, block) in blocks.enumerated() {
            let oldCount = self.result.count
            block()
            let newCount = self.result.count
            if oldCount != newCount && index != blocks.endIndex - 1 {
                line(times: linePadding)
            }
        }
        return self
    }

    @discardableResult
    public func append(_ describable: Describable) -> DescriptionPipe {
        describable.describe(into: self)
        return self
    }

    @discardableResult
    public func append<T: Describable>(_ describables: [T]) -> DescriptionPipe {
        describables.forEach {
            append($0)
        }
        return self
    }
}

extension DescriptionPipe: Describable {
    public func describe(into pipe: DescriptionPipe) {
        pipe.lines(result)
    }
}

public class DebugDescriptionPipe: DescriptionPipe {
    public override init() {
        super.init()
    }

    deinit {
        print(result.joined(separator: "\n"))
    }
}

public struct MethodParameter {
    public var label: String?
    public var name: String
    public var type: String
    public var defaultValue: String?

    public var description: String {
        return "\(label.format(into: { "\($0) " }))\(name): \(type)\(defaultValue.format(into: { " = \($0)" }))"
    }

    public init(label: String? = nil, name: String, type: String, defaultValue: String? = nil) {
        self.label = label
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }
}

public struct GenericParameter {
    public var name: String
    public var inheritance: String?

    public var description: String {
        return "\(name)\(inheritance.format(into: { ": \($0)" }))"
    }

    public init(name: String, inheritance: String? = nil) {
        self.name = name
        self.inheritance = inheritance
    }
}

public struct Function: HasAttributes, HasAccessibility, HasModifiers, Describable {
    public enum ThrowType {
        case throwing
        case rethrowing

        public var description: String {
            switch self {
            case .throwing:
                return "throws"
            case .rethrowing:
                return "rethrows"
            }
        }
    }
    public enum FunctionType {
        case standard
        case initializer
        case deinitializer

        public var isInitializer: Bool {
            switch self {
            case .initializer:
                return true
            default:
                return false
            }
        }

        public var isDeinitializer: Bool {
            switch self {
            case .deinitializer:
                return true
            default:
                return false
            }
        }
    }

    public var attributes: Attributes
    public var accessibility: Accessibility
    public var modifiers: DeclarationModifiers
    public var functionType: FunctionType
    public var name: String
    public var genericParameters: [GenericParameter]
    public var parameters: [MethodParameter]
    public var throwType: ThrowType?
    public var returnType: String?
    public var whereClause: [String]
    public var block: [String]

    public init(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, genericParameters: [GenericParameter] = [], parameters: [MethodParameter] = [], throwType: ThrowType? = nil, returnType: String? = nil, whereClause: [String] = [], block: [String] = []) {
        self.init(attributes: attributes, accessibility: accessibility, modifiers: modifiers, functionType: .standard, name: name, genericParameters: genericParameters, parameters: parameters, throwType: throwType, returnType: returnType, whereClause: whereClause, block: block)
    }

    private init(attributes: Attributes, accessibility: Accessibility, modifiers: DeclarationModifiers, functionType: FunctionType, name: String, genericParameters: [GenericParameter], parameters: [MethodParameter], throwType: ThrowType?, returnType: String?, whereClause: [String], block: [String]) {
        self.attributes = attributes
        self.accessibility = accessibility
        self.modifiers = modifiers
        self.functionType = functionType
        self.name = name
        self.genericParameters = genericParameters
        self.parameters = parameters
        self.throwType = throwType
        self.returnType = returnType
        self.whereClause = whereClause
        self.block = block
    }

    public static func initializer(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], optionalInit: Bool = false, genericParameters: [GenericParameter] = [], parameters: [MethodParameter] = [], throwType: ThrowType? = nil, whereClause: [String] = [], block: [String] = []) -> Function {
        return Function(attributes: attributes, accessibility: accessibility, modifiers: modifiers, functionType: .initializer, name: "init\(optionalInit ? "?" : "")", genericParameters: genericParameters, parameters: parameters, throwType: throwType, returnType: nil, whereClause: whereClause, block: block)
    }

    public static func deinitializer(attributes: Attributes = [], block: [String] = []) -> Function {
        return Function(attributes: attributes, accessibility: .internal, modifiers: [], functionType: .deinitializer, name: "deinit", genericParameters: [], parameters: [], throwType: nil, returnType: nil, whereClause: [], block: block)
    }

    public func describe(into pipe: DescriptionPipe) {
        describe(into: pipe, shouldOmitBody: false)
    }

    public func describe(into pipe: DescriptionPipe, shouldOmitBody: Bool) {
        let genericParametersString = genericParameters.map { $0.description }.joined(separator: ", ")
        let parametersString = parameters.map { $0.description }.joined(separator: ", ")

        attributes.describe(into: pipe)
        pipe.string([
            accessibility.description,
            modifiers.description,
            "\(functionType.isInitializer || functionType.isDeinitializer ? "" : "func")",
            "\(name)\(genericParameters.isEmpty ? "" : "<\(genericParametersString)>")\(functionType.isDeinitializer ? "" : "(\(parametersString))")",
            throwType?.description,
            returnType.format(into: { "-> \($0)" })
            ].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " "))

        if !whereClause.isEmpty {
            pipe.string(" where \(whereClause.joined(separator: ", "))")
        }
        guard !shouldOmitBody else { return }
        pipe.string(" ")
        pipe.block {
            pipe.lines(block)
        }
    }
}

public struct Property: HasAttributes, HasAccessibility, HasModifiers, Describable {
    public var attributes: Attributes
    public var accessibility: Accessibility
    public var modifiers: DeclarationModifiers
    public var isConstant: Bool
    public var name: String
    public var type: String?
    public var value: String?
    public var block: [String]?

    public static func variable(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, type: String? = nil, value: String) -> Property {
        return Property(
            attributes: attributes,
            accessibility: accessibility,
            modifiers: modifiers,
            isConstant: false,
            name: name,
            type: type,
            value: value,
            block: nil
        )
    }

    public static func variable(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, type: String, value: String? = nil, block: [String]? = nil) -> Property {
        return Property(
            attributes: attributes,
            accessibility: accessibility,
            modifiers: modifiers,
            isConstant: false,
            name: name,
            type: type,
            value: value,
            block: block
        )
    }
    //
    //    static func variable(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, type: String? = nil, value: String, block: [String]? = nil) -> Property {
    //        return Property(
    //            attributes: attributes,
    //            accessibility: accessibility,
    //            modifiers: modifiers,
    //            isConstant: false,
    //            name: name,
    //            type: type,
    //            value: value,
    //            block: block
    //        )
    //    }

    public static func constant(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, value: String) -> Property {
        return Property(
            attributes: attributes,
            accessibility: accessibility,
            modifiers: modifiers,
            isConstant: true,
            name: name,
            type: nil,
            value: value,
            block: nil
        )
    }

    public static func constant(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, type: String) -> Property {
        return Property(
            attributes: attributes,
            accessibility: accessibility,
            modifiers: modifiers,
            isConstant: true,
            name: name,
            type: type,
            value: nil,
            block: nil
        )
    }

    public static func constant(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, type: String, value: String) -> Property {
        return Property(
            attributes: attributes,
            accessibility: accessibility,
            modifiers: modifiers,
            isConstant: true,
            name: name,
            type: type,
            value: value,
            block: nil
        )
    }

    private init(attributes: Attributes, accessibility: Accessibility, modifiers: DeclarationModifiers, isConstant: Bool, name: String, type: String?, value: String?, block: [String]?) {
        self.attributes = attributes
        self.accessibility = accessibility
        self.modifiers = modifiers
        self.isConstant = isConstant
        self.name = name
        self.type = type
        self.value = value
        self.block = block
    }

    public func describe(into pipe: DescriptionPipe) {
        let typeString = type.format(into: { ": \($0)" })
        let valueString = value.format(into: { "= \($0)" })

        attributes.describe(into: pipe)
        pipe.string([accessibility.description, modifiers.description, "\(isConstant ? "let" : "var")", "\(name)\(typeString)", valueString].filter { !$0.isEmpty }.joined(separator: " "))
        if let block = block {
            pipe.string(" ")
            pipe.block {
                pipe.lines(block)
            }
        } else {
            pipe.lineEnd()
        }
    }
}

public protocol ContainerType: Describable {}

public struct Structure: ContainerType, HasAttributes, HasAccessibility {
    public enum Kind: CustomStringConvertible {
        case `struct`
        case `class`(isFinal: Bool)
        case `enum`(cases: [EnumCase])
        case `extension`

        public var description: String {
            switch self {
            case .struct:
                return "struct"
            case .class(isFinal: true):
                return "final class"
            case .class(isFinal: false):
                return "class"
            case .enum:
                return "enum"
            case .extension:
                return "extension"
            }
        }

        public var cases: [EnumCase] {
            switch self {
            case .struct, .class, .extension:
                return []
            case .enum(let cases):
                return cases
            }
        }
    }

    public var attributes: Attributes
    public var accessibility: Accessibility
    public var kind: Kind
    public var name: String
    public var genericParameters: [GenericParameter]
    public var inheritances: [String]
    public var whereClause: [String]
    public var containers: [ContainerType]
    public var properties: [Property]
    public var functions: [Function]

    public static func `class`(attributes: Attributes = [], accessibility: Accessibility = .internal, isFinal: Bool = false, name: String, genericParameters: [GenericParameter] = [], inheritances: [String] = [], whereClause: [String] = [], containers: [ContainerType] = [], properties: [Property] = [], functions: [Function] = []) -> Structure {

        return Structure(
            attributes: attributes,
            accessibility: accessibility,
            kind: .class(isFinal: isFinal),
            name: name,
            genericParameters: genericParameters,
            inheritances: inheritances,
            whereClause: whereClause,
            containers: containers,
            properties: properties,
            functions: functions)
    }

    public static func `struct`(attributes: Attributes = [], accessibility: Accessibility = .internal, name: String, genericParameters: [GenericParameter] = [], inheritances: [String] = [], whereClause: [String] = [], containers: [ContainerType] = [], properties: [Property] = [], functions: [Function] = []) -> Structure {

        return Structure(
            attributes: attributes,
            accessibility: accessibility,
            kind: .struct,
            name: name,
            genericParameters: genericParameters,
            inheritances: inheritances,
            whereClause: whereClause,
            containers: containers,
            properties: properties,
            functions: functions)
    }

    public static func `enum`(attributes: Attributes = [], accessibility: Accessibility = .internal, name: String, genericParameters: [GenericParameter] = [], inheritances: [String] = [], whereClause: [String] = [], containers: [ContainerType] = [], cases: [EnumCase], properties: [Property] = [], functions: [Function] = []) -> Structure {

        return Structure(
            attributes: attributes,
            accessibility: accessibility,
            kind: .enum(cases: cases),
            name: name,
            genericParameters: genericParameters,
            inheritances: inheritances,
            whereClause: whereClause,
            containers: containers,
            properties: properties,
            functions: functions)
    }

    public static func `extension`(attributes: Attributes = [], accessibility: Accessibility = .internal, extendedType: String, inheritances: [String] = [], whereClause: [String] = [], containers: [ContainerType] = [], properties: [Property] = [], functions: [Function] = []) -> Structure {

        return Structure(
            attributes: attributes,
            accessibility: accessibility,
            kind: .extension,
            name: extendedType,
            genericParameters: [],
            inheritances: inheritances,
            whereClause: whereClause,
            containers: containers,
            properties: properties,
            functions: functions)
    }

    public func describe(into pipe: DescriptionPipe) {
        let inheritancesString = inheritances.joined(separator: ", ")
        attributes.describe(into: pipe)
        let genericParametersString = genericParameters.map { $0.description }.joined(separator: ", ")
        pipe.string([accessibility.description, "\(kind) \(name)\(genericParameters.isEmpty ? "" : "<\(genericParametersString)>")\(!inheritancesString.isEmpty ? ": \(inheritancesString)" : "")"].filter { !$0.isEmpty }.joined(separator: " "))
        pipe.string(" ")
        pipe.block {
            pipe.spaced(linePadding: 1, describables: [
                (linePadding: 0, describables: containers),
                (linePadding: 0, kind.cases),
                (linePadding: 0, describables: properties),
                (linePadding: 1, describables: functions),
            ])
        }
    }
}

extension Structure {
    public struct EnumCase: Describable {
        public typealias Argument = (name: String?, type: String)

        public var isIndirect: Bool
        public var name: String
        public var arguments: [Argument]

        public func describe(into pipe: DescriptionPipe) {
            let argumentsString: String
            if arguments.isEmpty {
                argumentsString = ""
            } else {
                let mappedArguments = arguments.map { argument in
                    argument.name.format(into: { "\($0): " }) + argument.type
                }
                argumentsString = "(\(mappedArguments.joined(separator: ", ")))"
            }
            pipe.line("case \(name)\(argumentsString)")
        }

        public init(name: String, arguments: [Argument] = []) {
            self.init(isIndirect: false, name: name, arguments: arguments)
        }

        private init(isIndirect: Bool, name: String, arguments: [Argument]) {
            self.isIndirect = isIndirect
            self.name = name
            self.arguments = arguments
        }

        public static func indirect(name: String, arguments: [Argument]) -> EnumCase {
            return EnumCase(isIndirect: true, name: name, arguments: arguments)
        }
    }
}

public enum GenerationError: Error {
    case unknown
    case missingField
}

public struct Protocol: ContainerType, HasAttributes, HasAccessibility {
    public struct ProtocolProperty: Describable {
        public enum PropertyType {
            case get
            case getSet

            public var description: String {
                switch self {
                case .get:
                    return "get"
                case .getSet:
                    return "get set"
                }
            }
        }

        public var attributes: Attributes
        public var accessibility: Accessibility
        public var modifiers: DeclarationModifiers
        public var name: String
        public var type: String
        public var propertyType: PropertyType

        public init(attributes: Attributes = [], accessibility: Accessibility = .internal, modifiers: DeclarationModifiers = [], name: String, type: String, propertyType: PropertyType) {
            self.attributes = attributes
            self.accessibility = accessibility
            self.modifiers = modifiers
            self.name = name
            self.type = type
            self.propertyType = propertyType
        }

        public static func from(property: Property, propertyTypeHint: PropertyType? = nil) throws -> ProtocolProperty {
            guard let type = property.type else {
                throw GenerationError.missingField
            }
            let propertyType = propertyTypeHint ?? (property.isConstant && property.block?.isEmpty ?? true ? .get : .getSet)
            return ProtocolProperty(attributes: property.attributes, accessibility: property.accessibility, modifiers: property.modifiers, name: property.name, type: type, propertyType: propertyType)
        }

        public func describe(into pipe: DescriptionPipe) {
            attributes.describe(into: pipe)
            pipe.line([accessibility.description, modifiers.description, "var", "\(name): \(type)", "{ \(propertyType.description) }"].filter { !$0.isEmpty }.joined(separator: " "))
        }
    }

    public var attributes: Attributes
    public var accessibility: Accessibility
    public var name: String
    public var genericParameters: [(name: String, inheritance: String?)]
    public var inheritances: [String]
    public var properties: [ProtocolProperty]
    public var functions: [Function]

    public init(attributes: Attributes = [], accessibility: Accessibility = .internal, name: String, genericParameters: [(name: String, inheritance: String?)] = [], inheritances: [String] = [], properties: [ProtocolProperty] = [], functions: [Function] = []) {
        self.attributes = attributes
        self.accessibility = accessibility
        self.name = name
        self.genericParameters = genericParameters
        self.inheritances = inheritances
        self.properties = properties
        self.functions = functions
    }

    public func describe(into pipe: DescriptionPipe) {
        let inheritancesString = inheritances.joined(separator: ", ")
        attributes.describe(into: pipe)
        pipe.string([accessibility.description, "protocol \(name)\(inheritancesString.isEmpty ? inheritancesString : "")"].filter { !$0.isEmpty }.joined(separator: " "))
        pipe.string(" ")
        pipe.block {
            pipe.lines(genericParameters.map { "associatedtype \($0.name)\($0.inheritance.format(into: { ": \($0)" }))" })
            pipe.line()
            pipe.spaced(linePadding: 0, describables: properties)
            pipe.line()
            for (index, function) in functions.enumerated() {
                function.describe(into: pipe, shouldOmitBody: true)
                if index != functions.endIndex - 1 {
                    pipe.line()
                }
            }
        }
    }
}

//public struct Extension: ContainerType, HasAttributes, HasAccessibility {
//    public var attributes: Attributes
//    public var accessibility: Accessibility
//    public var extendedType: String
//    public var inheritances: [String]
//    public var whereClause: [String]
//    public var properties: [Property]
//    public var functions: [Function]
//
//    public init(attributes: Attributes = [], accessibility: Accessibility = .internal, extendedType: String, inheritances: [String] = [], whereClause: [String], properties: [Property] = [], functions: [Function] = []) {
//        self.attributes = attributes
//        self.accessibility = accessibility
//        self.extendedType = extendedType
//        self.inheritances = inheritances
//        self.whereClause = whereClause
//        self.properties = properties
//        self.functions = functions
//    }
//
//    public func describe(into pipe: DescriptionPipe) {
//        let inheritancesString = inheritances.joined(separator: ", ")
//        attributes.describe(into: pipe)
//        pipe.string([accessibility.description, "extension \(extendedType)\(inheritancesString.isEmpty ? inheritancesString : "")"].filter { !$0.isEmpty }.joined(separator: " "))
//        if !whereClause.isEmpty {
//            pipe.string(" where \(whereClause.joined(separator: ", "))")
//        }
//        pipe.string(" ")
//        pipe.block {
//            pipe.spaced(describables: properties + functions)
//        }
//    }
//}

//public struct Enumeration: ContainerType, HasAttributes, HasAccessibility {
//
//
//    public var attributes: Attributes
//    public var accessibility: Accessibility
//    public var name: String
//    public var inheritances: [String]
//    public var containers: [ContainerType]
//    public var cases: [Case]
//    public var properties: [Property]
//    public var functions: [Function]
//
//    public init(attributes: Attributes = [], accessibility: Accessibility = .internal, name: String, inheritances: [String] = [], containers: [ContainerType] = [], cases: [Case], properties: [Property] = [], functions: [Function] = []) {
//        self.attributes = attributes
//        self.accessibility = accessibility
//        self.name = name
//        self.inheritances = inheritances
//        self.containers = containers
//        self.cases = cases
//        self.properties = properties
//        self.functions = functions
//    }
//
//    public func describe(into pipe: DescriptionPipe) {
//        let inheritancesString = inheritances.joined(separator: ", ")
//        attributes.describe(into: pipe)
//        pipe.string([accessibility.description, "enum \(name)\(inheritancesString.isEmpty ? inheritancesString : "")"].filter { !$0.isEmpty }.joined(separator: " "))
//        pipe.string(" ")
//        pipe.block {
//            pipe.spaced(describables: containers)
//            pipe.line()
//            pipe.lines(cases.map { $0.description })
//            pipe.line()
//            pipe.spaced(describables: properties + functions)
//        }
//    }
//}
