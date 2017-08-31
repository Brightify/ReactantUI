import SpriteKit
import Foundation

public enum Color {
    case absolute(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    case named(String)

    /// Accepted formats: "#RRGGBB" and "#RRGGBBAA".
    init?(hex: String) {
        let hexNumber = String(hex.characters.dropFirst())
        let length = hexNumber.characters.count
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

    public var skColor: SKColor {
        switch self {
        case .absolute(let red, let green, let blue, let alpha):
            return SKColor(red: red, green: green, blue: blue, alpha: alpha)
        case .named(let name):
            switch name {
            case "clear":
                return SKColor.clear
            case "red":
                return SKColor.red
            case "green":
                return SKColor.green
            case "blue":
                return SKColor.blue
            case "white":
                return SKColor.white
            case "black":
                return SKColor.black
            default:
                return SKColor.red
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
