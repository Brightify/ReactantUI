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
        // we're not creating our own parser for this, so we will disallow using dots inside the values and instead enforce
        // using percent signs
        let colorComponents = value.components(separatedBy: "@")

        func getColor(from value: String) throws -> UIColorPropertyType {
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

        let base = try getColor(from: colorComponents[0])

        guard colorComponents.count > 1 else { return base }
        // note the `var color` that we're going to apply the modificators to
        guard case .color(var color) = base else {
            throw ParseError.message("Only direct colors support modifications for now.")
        }

        for colorComponent in colorComponents.dropFirst() {
            let procedure = try SimpleProcedure(from: colorComponent)
            // all of the current modifications require just one parameter
            // feel free to change this in case you add a method that needs more than one
            guard let parameter = procedure.parameters.first, procedure.parameters.count == 1 else {
                throw ParseError.message("Wrong number (\(procedure.parameters.count)) of parameters in procedure \(procedure.name).")
            }

            if let label = parameter.label {
                // right now all the modifications can have the `by:` label, no other
                let correctLabel = "by"
                guard label == correctLabel else {
                    throw ParseError.message("Wrong label \(label) inside procedure \(procedure.name). \"\(correctLabel)\" or none should be used instead.")
                }
            }

            let trimmedValue = parameter.value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            let floatValue: CGFloat
            if let probablePercentSign = trimmedValue.last, probablePercentSign == "%", let value = Int(trimmedValue.dropLast()) {
                floatValue = CGFloat(value) / 100
            } else if let value = Float(trimmedValue) {
                floatValue = CGFloat(value)
            } else {
                throw ParseError.message("\(parameter.value) is not a valid integer (with percent sign) nor floating point number to denote the value of the parameter in procedure \(procedure.name).")
            }

            switch procedure.name {
            case "lighter":
                color = color.lighter(by: floatValue)
            case "darker":
                color = color.darker(by: floatValue)
            case "saturated":
                color = color.saturated(by: floatValue)
            case "desaturated":
                color = color.desaturated(by: floatValue)
            case "fadedOut":
                color = color.fadedOut(by: floatValue)
            case "fadedIn":
                color = color.fadedIn(by: floatValue)
            case "alpha":
                color = color.withAlphaComponent(floatValue)
            default:
                throw ParseError.message("Unknown procedure \(procedure.name) used on color \(colorComponents[0]).")
            }
        }
        return .color(color)
    }

    public static var xsdType: XSDType {
        return Color.xsdType
    }
}
