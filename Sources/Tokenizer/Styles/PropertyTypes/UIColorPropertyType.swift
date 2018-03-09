//
//  UIColorPropertyType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

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

    public static var xsdType: XSDType {
        return Color.xsdType
    }
}
