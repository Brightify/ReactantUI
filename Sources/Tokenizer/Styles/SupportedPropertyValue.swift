import Foundation
#if ReactantRuntime
import UIKit
import MapKit
import Reactant
#endif

public enum SupportedPropertyValue {
    case color(Color, Color.RuntimeType)
    case namedColor(String, Color.RuntimeType)
    case string(String)
    case font(Font)
    case integer(Int)
    case textAlignment(TextAlignment)
    case contentMode(ContentMode)
    case image(String)
    case layoutAxis(vertical: Bool)
    case layoutDistribution(LayoutDistribution)
    case layoutAlignment(LayoutAlignment)
    case float(Float)
    case double(Double)
    case bool(Bool)
    case rectEdge([RectEdge])
    case activityIndicatorStyle(ActivityIndicatorStyle)
    case visibility(ViewVisibility)
    case collapseAxis(ViewCollapseAxis)
    case rect(Rect)
    case size(Size)
    case point(Point)
    case edgeInsets(EdgeInsets)
    case datePickerMode(DatePickerMode)
    case barStyle(BarStyle)
    case searchBarStyle(SearchBarStyle)
    case blurEffect(BlurEffect)
    case vibrancyEffect(BlurEffect)
    case mapType(MapType)

    public var generated: String {
        switch self {
        case .color(let color, let type):
            let result = "UIColor(red: \(color.red), green: \(color.green), blue: \(color.blue), alpha: \(color.alpha))"
            return type == .uiColor ? result : result + ".cgColor"
        case .namedColor(let colorName, let type):
            let result = "UIColor.\(colorName)"
            return type == .uiColor ? result : result + ".cgColor"
        case .string(let string):
            if string.hasPrefix("localizable(") {
                let key = string.replacingOccurrences(of: "localizable(", with: "")
                    .replacingOccurrences(of: ")", with: "").trimmingCharacters(in: CharacterSet.whitespaces)
                return "NSLocalizedString(\"\(key)\", comment: \"\")"
            } else {
                return "\"\(string)\""
            }
        case .font(let font):
            switch font {
            case .system(let weight, let size):
                return "UIFont.systemFont(ofSize: \(size), weight: \(weight.name))"
            }
        case .integer(let value):
            return "\(value)"
        case .textAlignment(let value):
            return "NSTextAlignment.\(value.rawValue)"
        case .contentMode(let value):
            return "UIViewContentMode.\(value.rawValue)"
        case .image(let name):
            return "UIImage(named: \"\(name)\")"
        case .layoutAxis(let vertical):
            return vertical ? "UILayoutConstraintAxis.vertical" : "UILayoutConstraintAxis.horizontal"
        case .float(let value):
            return "\(value)"
        case .double(let value):
            return "\(value)"
        case .layoutDistribution(let distribution):
            return "UIStackViewDistribution.\(distribution.rawValue)"
        case .layoutAlignment(let alignment):
            return "UIStackViewAlignment.\(alignment.rawValue)"
        case .bool(let value):
            return value ? "true" : "false"
        case .rectEdge(let rectEdges):
            return "[\(rectEdges.map { "UIRectEdge.\($0.rawValue)" }.joined(separator: ", "))]"
        case .activityIndicatorStyle(let style):
            return "UIActivityIndicatorViewStyle.\(style.rawValue)"
        case .visibility(let visibility):
            return "Visibility.\(visibility.rawValue)"
        case .collapseAxis(let axis):
            return "CollapseAxis.\(axis.rawValue)"
        case .rect(let rect):
            return "CGRect(origin: CGPoint(x: \(rect.origin.x.cgFloat), y: \(rect.origin.y.cgFloat)), size: CGSize(width: \(rect.size.width.cgFloat), height: \(rect.size.height.cgFloat)))"
        case .point(let point):
            return "CGPoint(x: \(point.x.cgFloat), y: \(point.y.cgFloat))"
        case .size(let size):
            return "CGSize(width: \(size.width.cgFloat), height: \(size.height.cgFloat))"
        case .edgeInsets(let insets):
            return "UIEdgeInsetsMake(\(insets.top.cgFloat), \(insets.left.cgFloat), \(insets.bottom.cgFloat), \(insets.right.cgFloat))"
        case .datePickerMode(let mode):
            return "UIDatePickerMode.\(mode.rawValue)"
        case .barStyle(let style):
            return "UIBarStyle.\(style.rawValue)"
        case .searchBarStyle(let style):
            return "UISearchBarStyle.\(style.rawValue)"
        case .blurEffect(let effect):
            return "UIBlurEffect(style: .\(effect.rawValue))"
        case .vibrancyEffect(let effect):
            return "UIVibrancyEffect(blurEffect: .\(effect.rawValue))"
        case .mapType(let type):
            return "MKMapType.\(type.rawValue)"
        }
    }

    #if ReactantRuntime
    public var value: Any? {
        switch self {
        case .color(let color, let type):
            let result = color.value as? UIColor
            return type == .uiColor ? result : result?.cgColor
        case .namedColor(let colorName, let type):
            let result = UIColor.value(forKeyPath: "\(colorName)Color") as? UIColor
            return type == .uiColor ? result : result?.cgColor
        case .string(let string):
            if string.hasPrefix("localizable(") {
                let key = string.replacingOccurrences(of: "localizable(", with: "")
                    .replacingOccurrences(of: ")", with: "").trimmingCharacters(in: CharacterSet.whitespaces)
                return NSLocalizedString(key, comment: "")
            } else {
                return string
            }
        case .font(let font):
            return font.value
        case .integer(let value):
            return value
        case .textAlignment(let alignment):
            return alignment.value
        case .contentMode(let mode):
            return mode.value
        case .image(let name):
            return UIImage(named: name)
        case .layoutAxis(let vertical):
            return vertical ? UILayoutConstraintAxis.vertical.rawValue : UILayoutConstraintAxis.horizontal.rawValue
        case .float(let value):
            return value
        case .double(let value):
            return value
        case .layoutDistribution(let distribution):
            return distribution.value
        case .layoutAlignment(let alignment):
            return alignment.value
        case .bool(let value):
            return value
        case .rectEdge(let rectEdges):
            return rectEdges.resolveUnion().rawValue
        case .activityIndicatorStyle(let style):
            return style.value
        case .visibility(let visibility):
            return visibility.value
        case .collapseAxis(let axis):
            return axis.value
        case .rect(let rect):
            return rect.value
        case .point(let point):
            return point.value
        case .size(let size):
            return size.value
        case .edgeInsets(let insets):
            return insets.value
        case .datePickerMode(let mode):
            return mode.value
        case .barStyle(let style):
            return style.value
        case .searchBarStyle(let style):
            return style.value
        case .blurEffect(let effect):
            return effect.value
        case .vibrancyEffect(let effect):
            guard let blurEffect = effect.value as? UIBlurEffect else { return nil }
            return UIVibrancyEffect(blurEffect: blurEffect)
        case .mapType(let type):
            return type.value
        }
    }
    #endif
}
