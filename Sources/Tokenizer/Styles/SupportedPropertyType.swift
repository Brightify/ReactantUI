//
//  SupportedPropertyType.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if ReactantRuntime
import UIKit
#endif

import Foundation

public enum PropertyMaterializationError: Error {
    case unknownValue(String)
}

public protocol SupportedPropertyType {
    var generated: String { get }
    
    #if SanAndreas
    func dematerialize() -> String
    #endif

    #if ReactantRuntime
    var runtimeValue: Any? { get }
    #endif

    static func materialize(from value: String) throws -> Self
}

public struct CGColorPropertyType: SupportedPropertyType {
    public let color: UIColorPropertyType

    public var generated: String {
        return "\(color.generated).cgColor"
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
    return color.dematerialize()
    }
    #endif

    #if ReactantRuntime
    public var runtimeValue: Any? {
        return (color.runtimeValue as? UIColor)?.cgColor
    }
    #endif

    public init(color: UIColorPropertyType) {
        self.color = color
    }

    public static func materialize(from value: String) throws -> CGColorPropertyType {
        let materializedValue = try UIColorPropertyType.materialize(from: value)
        return CGColorPropertyType(color: materializedValue)
    }
}

public struct UIColorPropertyType: SupportedPropertyType {
    public let color: Color

    public var generated: String {
        switch color {
        case .absolute(let red, let green, let blue, let alpha):
            return "UIColor(red: \(red), green: \(green), blue: \(blue), alpha: \(alpha))"
        case .named(let name):
            return "UIColor.\(name)"
        }
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
        switch color {
        case .absolute(let red, let green, let blue, let alpha):
            if alpha < 1 {
                let rgba: Int = Int(red * 255) << 24 | Int(green * 255) << 16 | Int(blue * 255) << 8 | Int(alpha * 255)
                return String(format:"#%08x", rgba)
            } else {
                let rgb: Int = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255)
                return String(format:"#%06x", rgb)
            }

        case .named(let name):
            return name
        }
    }
    #endif

    #if ReactantRuntime
    public var runtimeValue: Any? {
        switch color {
        case .absolute(let red, let green, let blue, let alpha):
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        case .named(let name):
            return UIColor.value(forKeyPath: "\(name)Color") as? UIColor
        }
    }
    #endif

    public init(color: Color) {
        self.color = color
    }

    public static func materialize(from value: String) throws -> UIColorPropertyType {
        if Color.supportedNames.contains(value) {
            return UIColorPropertyType(color: .named(value))
        } else if let materializedValue = Color(hex: value) {
            return UIColorPropertyType(color: materializedValue)
        } else {
            throw PropertyMaterializationError.unknownValue(value)
        }
    }
}

extension TransformedText: SupportedPropertyType {
    public var generated: String {
        func resolveTransformations(text: TransformedText) -> String {
            switch text {
            case .transform(.uppercased, let inner):
                return resolveTransformations(text: inner) + ".uppercased()"
            case .transform(.lowercased, let inner):
                return resolveTransformations(text: inner) + ".lowercased()"
            case .transform(.localized, let inner):
                return "NSLocalizedString(\(resolveTransformations(text: inner)), comment: \"\")"
            case .transform(.capitalized, let inner):
                return resolveTransformations(text: inner) + ".capitalized"
            case .text(let value):
                return "\"\(value)\""
            }
        }
        return resolveTransformations(text: self)
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
        func resolveTransformations(text: TransformedText) -> String {
            switch text {
            case .transform(.uppercased, let inner):
                return ":uppercased(\(resolveTransformations(text: inner)))"
            case .transform(.lowercased, let inner):
                return ":lowercased(\(resolveTransformations(text: inner)))"
            case .transform(.localized, let inner):
                return ":localized(\(resolveTransformations(text: inner)))"
            case .transform(.capitalized, let inner):
                return ":capitalized(\(resolveTransformations(text: inner)))"
            case .text(let value):
                return value
            }
        }
        return resolveTransformations(text: self)
    }
    #endif

    #if ReactantRuntime
    public var runtimeValue: Any? {
        func resolveTransformations(text: TransformedText) -> String {
            switch text {
            case .transform(.uppercased, let inner):
                return resolveTransformations(text: inner).uppercased()
            case .transform(.lowercased, let inner):
                return resolveTransformations(text: inner).lowercased()
            case .transform(.localized, let inner):
                return NSLocalizedString(resolveTransformations(text: inner), comment: "")
            case .transform(.capitalized, let inner):
                return resolveTransformations(text: inner).capitalized
            case .text(let value):
                return value
            }
        }
        return resolveTransformations(text: self)
    }
    #endif

    public static func materialize(from value: String) throws -> TransformedText {
        let tokens = Lexer.tokenize(input: value, keepWhitespace: true)
        return try TextParser(tokens: tokens).parseSingle()
    }
}

//struct EnumPropertyType<T: RawRepresentable>: SupportedPropertyType where T.RawValue == String {
//    private let value: T
//
//    init(value: T) {
//        self.value = value
//    }
//
//    var generated: String {
//        return value.rawValue
//    }
//
//    static func materialize(from value: String) throws -> EnumPropertyType<T> {
//        guard let materializedValue = T(rawValue: value) else {
//            throw PropertyMaterializationError.unknownValue(value)
//        }
//        return EnumPropertyType(value: materializedValue)
//    }
//}

public protocol EnumPropertyType: RawRepresentable, SupportedPropertyType {
    static var enumName: String { get }
}

extension EnumPropertyType where Self.RawValue == String {
    public var generated: String {
        return "\(Self.enumName).\(rawValue)"
    }
}

extension SupportedPropertyType where Self: RawRepresentable, Self.RawValue == String {
    #if SanAndreas
    public func dematerialize() -> String {
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

extension Bool: SupportedPropertyType {
    public var generated: String {
        return self ? "true" : "false"
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
        return generated
    }
    #endif

    #if ReactantRuntime
    public var runtimeValue: Any? {
        return self
    }
    #endif

    public static func materialize(from value: String) throws -> Bool {
        guard let materialized = Bool(value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }
}

extension Float: SupportedPropertyType {

    public var generated: String {
        return "\(self)"
    }

    #if ReactantRuntime
    public var runtimeValue: Any? {
        return self
    }
    #endif
    
    #if SanAndreas
    public func dematerialize() -> String {
        return generated
    }
    #endif
    
    public static func materialize(from value: String) throws -> Float {
        guard let materialized = Float(value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }
}

extension Double: SupportedPropertyType {
    public var generated: String {
        return "\(self)"
    }

    #if ReactantRuntime
    public var runtimeValue: Any? {
        return self
    }
    #endif
    
    #if SanAndreas
    public func dematerialize() -> String {
        return generated
    }
    #endif

    public static func materialize(from value: String) throws -> Double {
        guard let materialized = Double(value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }
}

extension Int: SupportedPropertyType {
    public var generated: String {
        return "\(self)"
    }

    #if ReactantRuntime
    public var runtimeValue: Any? {
        return self
    }
    #endif
    
    #if SanAndreas
    public func dematerialize() -> String {
        return generated
    }
    #endif

    public static func materialize(from value: String) throws -> Int {
        guard let materialized = Int(value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }
}

//public struct ArrayPropertyType<T: SupportedPropertyType>: SupportedPropertyType {
//    public var generated: String
//
//    public let values: [T]
//
//    public init(values: [T]) {
//        self.values = values
//    }
//
//    public static func materialize(from value: String) throws -> ArrayPropertyType<T> {
//        let components = value.components(separatedBy: CharacterSet.whitespacesAndNewlines)
//        return try ArrayPropertyType(values: components.flatMap(T.materialize(from:)))
//    }
//}

//public enum SupportedPropertyType2 {
//    case color(Color.RuntimeType)
//    case string
//    case font
//    case integer
//    case textAlignment
//    case contentMode
//    case image
//    case layoutAxis
//    case layoutDistribution
//    case layoutAlignment
//    case float
//    case double
//    case bool
//    case rectEdge
//    case activityIndicatorStyle
//    case visibility
//    case collapseAxis
//    case rect
//    case size
//    case point
//    case edgeInsets
//    case datePickerMode
//    case barStyle
//    case searchBarStyle
//    case visualEffect
//    case mapType
//    case lineBreakMode
//    case textBorderStyle
//    case textFieldViewMode
//    case scrollViewIndicatorStyle
//    case keyboardAppearance
//    case keyboardType
//    case textContentType
//    case returnKeyType
//
//    public func value(of text: String) -> SupportedPropertyValue? {
//        switch self {
//        case .color(let type):
//            if Color.supportedNames.contains(text) {
//                return .namedColor(text, type)
//            } else {
//                return Color(hex: text).map { SupportedPropertyValue.color($0, type) }
//            }
//        case .string:
//            let tokens = Lexer.tokenize(input: text, keepWhitespace: true)
//            return (try? TextParser(tokens: tokens).parseSingle()).map(SupportedPropertyValue.string)
//        case .font:
//            let tokens = Lexer.tokenize(input: text, keepWhitespace: true)
//            return (try? FontParser(tokens: tokens).parseSingle()).map(SupportedPropertyValue.font)
//        case .integer:
//            return Int(text).map(SupportedPropertyValue.integer)
//        case .textAlignment:
//            return TextAlignment(rawValue: text).map(SupportedPropertyValue.textAlignment)
//        case .contentMode:
//            return ContentMode(rawValue: text).map(SupportedPropertyValue.contentMode)
//        case .image:
//            return .image(text)
//        case .layoutAxis:
//            return .layoutAxis(vertical: text == "vertical" ? true : false)
//        case .layoutDistribution:
//            return LayoutDistribution(rawValue: text).map(SupportedPropertyValue.layoutDistribution)
//        case .layoutAlignment:
//            return LayoutAlignment(rawValue: text).map(SupportedPropertyValue.layoutAlignment)
//        case .float:
//            return Float(text).map(SupportedPropertyValue.float)
//        case .double:
//            return Double(text).map(SupportedPropertyValue.double)
//        case .bool:
//            return Bool(text).map(SupportedPropertyValue.bool)
//        case .rectEdge:
//            return SupportedPropertyValue.rectEdge(RectEdge.parse(text: text))
//        case .activityIndicatorStyle:
//            return ActivityIndicatorStyle(rawValue: text).map(SupportedPropertyValue.activityIndicatorStyle)
//        case .visibility:
//            return ViewVisibility(rawValue: text).map(SupportedPropertyValue.visibility)
//        case .collapseAxis:
//            return ViewCollapseAxis(rawValue: text).map(SupportedPropertyValue.collapseAxis)
//        case .rect:
//            let parts = text.components(separatedBy: ",").flatMap(Float.init)
//            guard parts.count == 4 else { return nil }
//            return .rect(Rect(x: parts[0], y: parts[1], width: parts[2], height: parts[3]))
//        case .point:
//            let parts = text.components(separatedBy: ",").flatMap(Float.init)
//            guard parts.count == 2 else { return nil }
//            return .point(Point(x: parts[0], y: parts[1]))
//        case .size:
//            let parts = text.components(separatedBy: ",").flatMap(Float.init)
//            guard parts.count == 2 else { return nil }
//            return .size(Size(width: parts[0], height: parts[1]))
//        case .edgeInsets:
//            let parts = text.components(separatedBy: ",").flatMap(Float.init)
//            guard parts.count == 4 || parts.count == 2 else { return nil }
//            if parts.count == 4 {
//                return .edgeInsets(EdgeInsets(top: parts[0], left: parts[1], bottom: parts[2], right: parts[3]))
//            }
//            return .edgeInsets(EdgeInsets(top: parts[1], left: parts[0], bottom: parts[1], right: parts[0]))
//        case .datePickerMode:
//            return DatePickerMode(rawValue: text).map(SupportedPropertyValue.datePickerMode)
//        case .barStyle:
//            return BarStyle(rawValue: text).map(SupportedPropertyValue.barStyle)
//        case .searchBarStyle:
//            return SearchBarStyle(rawValue: text).map(SupportedPropertyValue.searchBarStyle)
//        case .visualEffect:
//            let parts = text.components(separatedBy: ":")
//            guard parts.count == 2 && (parts.first == "blur" || parts.first == "vibrancy") else { return nil }
//            guard let effect = BlurEffect(rawValue: parts[1]) else { return nil }
//            return parts.first == "blur" ? .blurEffect(effect) : .vibrancyEffect(effect)
//        case .mapType:
//            return MapType(rawValue: text).map(SupportedPropertyValue.mapType)
//        case .lineBreakMode:
//            return LineBreakMode(rawValue: text).map(SupportedPropertyValue.lineBreakMode)
//        case .textBorderStyle:
//            return TextBorderStyle(rawValue: text).map(SupportedPropertyValue.textBorderStyle)
//        case .textFieldViewMode:
//            return TextFieldViewMode(rawValue: text).map(SupportedPropertyValue.textFieldViewMode)
//        case .scrollViewIndicatorStyle:
//            return ScrollViewIndicatorStyle(rawValue: text).map(SupportedPropertyValue.scrollViewIndicatorStyle)
//        case .keyboardAppearance:
//            return KeyboardAppearance(rawValue: text).map(SupportedPropertyValue.keyboardAppearance)
//        case .keyboardType:
//            return KeyboardType(rawValue: text).map(SupportedPropertyValue.keyboardType)
//        case .textContentType:
//            return TextContentType(rawValue: text).map(SupportedPropertyValue.textContentType)
//        case .returnKeyType:
//            return ReturnKeyType(rawValue: text).map(SupportedPropertyValue.returnKeyType)
//        }
//    }
//}
