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
}

//public struct Color {
//    public enum RuntimeType {
//        case uiColor
//        case cgColor
//    }
//
//    public var red: CGFloat
//    public var green: CGFloat
//    public var blue: CGFloat
//    public var alpha: CGFloat
//
//    /// Accepted formats: "#RRGGBB" and "#RRGGBBAA".
//    init?(hex: String) {
//        let hexNumber = String(hex.characters.dropFirst())
//        let length = hexNumber.characters.count
//        guard length == 6 || length == 8 else {
//            return nil
//        }
//
//        if let hexValue = UInt(hexNumber, radix: 16) {
//            if length == 6 {
//                self.init(rgb: hexValue)
//            } else {
//                self.init(rgba: hexValue)
//            }
//        } else {
//            return nil
//        }
//    }
//
//    init(rgb: UInt) {
//        if rgb > 0xFFFFFF {
//            print("// WARNING: RGB color is greater than the value of white (0xFFFFFF) which is probably developer error.")
//        }
//        self.init(rgba: (rgb << 8) + 0xFF)
//    }
//
//    init(rgba: UInt) {
//        let red = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
//        let green = CGFloat((rgba & 0xFF0000) >> 16) / 255.0
//        let blue = CGFloat((rgba & 0xFF00) >> 8) / 255.0
//        let alpha = CGFloat(rgba & 0xFF) / 255.0
//
//    }
//}

//#if ReactantRuntime
//import UIKit
//
//extension Color {
//
//    public var runtimeValue: UIColor {
//        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
//    }
//}
//#endif
