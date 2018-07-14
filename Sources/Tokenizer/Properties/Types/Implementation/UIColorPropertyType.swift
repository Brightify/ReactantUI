//
//  UIColorPropertyType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#endif

public enum UIColorPropertyType: AttributeSupportedPropertyType {
    case color(Color)
    case themed(String)

    public var requiresTheme: Bool {
        switch self {
        case .color:
            return false
        case .themed:
            return true
        }
    }

    public func generate(context: SupportedPropertyTypeContext) -> String {
        switch self {
        case .color(.absolute(let red, let green, let blue, let alpha)):
            return "UIColor(red: \(red), green: \(green), blue: \(blue), alpha: \(alpha))"
        case .color(.named(let name)):
            return "UIColor.\(name)"
        case .themed(let name):
            return "theme.colors.\(name)"
        }
    }

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
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

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        switch self {
        case .color(.absolute(let red, let green, let blue, let alpha)):
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        case .color(.named(let name)):
            return UIColor.value(forKeyPath: "\(name)Color") as? UIColor
        case .themed(let name):
            guard let themedColor = context.themed(color: name) else { return nil }
            return themedColor.runtimeValue(context: context.sibling(for: themedColor))
        }
    }
    #endif

    public static func materialize(from value: String) throws -> UIColorPropertyType {
        if let themedName = ApplicationDescription.themedValueName(value: value) {
            return .themed(themedName)
        } else if Color.supportedNames.contains(value) {
            return .color(.named(value))
        } else if let materializedValue = Color(hex: value) {
            return .color(materializedValue)
        } else {
            throw PropertyMaterializationError.unknownValue(value)
        }
    }

    public static var xsdType: XSDType {
        return Color.xsdType
    }
}
