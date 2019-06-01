//
//  Color.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif
import Foundation

public enum Color {
    case absolute(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    case named(String)

    public static let black = Color.named("black")

    init(color: SystemColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self = Color.absolute(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// Accepted formats: "#RRGGBB" and "#RRGGBBAA".
    init?(hex: String) {
        let hexNumber = String(hex.dropFirst())
        let length = hexNumber.count
        guard length == 6 || length == 8 else {
            return nil
        }

        if let hexValue = UInt(hexNumber, radix: 16) {
            if length == 6 {
                self.init(rgb: hexValue)
            } else {
                self.init(rgba: hexValue)
            }
        } else {
            return nil
        }
    }

    init(rgb: UInt) {
        if rgb > 0xFFFFFF {
            print("// WARNING: RGB color is greater than the value of white (0xFFFFFF) which is probably developer error.")
        }
        self.init(rgba: (rgb << 8) + 0xFF)
    }

    init(rgba: UInt) {
        let red = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((rgba & 0xFF0000) >> 16) / 255.0
        let blue = CGFloat((rgba & 0xFF00) >> 8) / 255.0
        let alpha = CGFloat(rgba & 0xFF) / 255.0

        self = Color.absolute(red: red, green: green, blue: blue, alpha: alpha)
    }

    #if os(OSX)
        public typealias SystemColor = NSColor
    #else
        public typealias SystemColor = UIColor
    #endif

    public var color: SystemColor {
        switch self {
        case .absolute(let red, let green, let blue, let alpha):
            return SystemColor(red: red, green: green, blue: blue, alpha: alpha)
        case .named(let name):
            switch name {
            case "clear":
                return SystemColor.clear
            case "red":
                return SystemColor.red
            case "green":
                return SystemColor.green
            case "blue":
                return SystemColor.blue
            case "white":
                return SystemColor.white
            case "black":
                return SystemColor.black
            case "gray":
                return SystemColor.gray
            case "darkGray":
                return SystemColor.darkGray
            case "lightGray":
                return SystemColor.lightGray
            case "cyan":
                return SystemColor.cyan
            case "yellow":
                return SystemColor.yellow
            case "magenta":
                return SystemColor.magenta
            case "orange":
                return SystemColor.orange
            case "purple":
                return SystemColor.purple
            case "brown":
                return SystemColor.brown
            default:
                return SystemColor.red
            }
        }
    }

    static var xsdType: XSDType {
        let hexColor = PatternXSDType(name: "hexColor", base: .token, value: "#[\\dA-Fa-f]{6}([\\dA-Fa-f][\\dA-Fa-f])?")
        let colors = Set<String>(arrayLiteral: "clear", "red", "green", "blue", "white", "black", "gray", "darkGray", "lightGray", "cyan", "yellow",
                                 "magenta", "orange", "purple", "brown")
        let namedColor = EnumerationXSDType(name: "namedColor", base: .string, values: colors)
        return .union(UnionXSDType(name: "color", memberTypes: [.pattern(hexColor), .enumeration(namedColor)]))
    }
}

extension Color {
    func withAlphaComponent(_ value: CGFloat) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard getColorComponents(hue: &hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        alpha = min(1, max(0, value))
        return Color(color: SystemColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha))
    }

    /**
     * Increases color's brightness.
     * - parameter percent: determines by how much will the color get lighter
     * Expected values between 0.0-1.0
     */
    func lighter(by percent: CGFloat) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard getColorComponents(hue: &hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        brightness = adjust(brightness, by: percent)
        return Color(color: SystemColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha))
    }

    /**
     * Reduces color's brightness.
     * - parameter percent: determines by how much will the color get darker
     * Expected values between 0.0-1.0
     */
    func darker(by percent: CGFloat) -> Color {
        return lighter(by: -percent)
    }

    /**
     * Increases color's saturation.
     * - parameter percent: determines by how much will the color get saturated
     * Expected values between 0.0-1.0
     */
    func saturated(by percent: CGFloat) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard getColorComponents(hue: &hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        saturation = adjust(saturation, by: percent)
        return Color(color: SystemColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha))
    }

    /**
     * Reduces color's saturation.
     * - parameter percent: determines by how much will the color get desaturated
     * Expected values between 0.0-1.0
     */
    func desaturated(by percent: CGFloat) -> Color {
        return saturated(by: -percent)
    }

    /**
     * Increases color's alpha.
     * - parameter percent: determines by how much will the color's alpha increase
     * Expected values between 0.0-1.0
     */
    func fadedIn(by percent: CGFloat) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard getColorComponents(hue: &hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        alpha = adjust(alpha, by: percent)
        return Color(color: SystemColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha))
    }

    /**
     * Reduces color's alpha.
     * - parameter percent: determines by how much will the color's alpha decrease
     * Expected values between 0.0-1.0
     */
    func fadedOut(by percent: CGFloat) -> Color {
        return fadedIn(by: -percent)
    }

    private func getColorComponents(hue: inout CGFloat, saturation: inout CGFloat, brightness: inout CGFloat, alpha: inout CGFloat) -> Bool {
        #if os(iOS) || os(tvOS)
        guard color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return false }
        #else
        guard let colorSpacedColor = color.usingColorSpace(.deviceRGB) else { return false }
        colorSpacedColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        #endif
        return true
    }

    private func adjust(_ value: CGFloat, by amount: CGFloat) -> CGFloat {
        return min(max(0, value + value * amount), 1)
    }
}
