import Foundation

#if ReactantRuntime
import UIKit
#endif

public class Label: View {
    public static let text = assignable(name: "text", type: TransformedText.self)
    public static let textColor = assignable(name: "textColor", type: UIColorPropertyType.self)
    public static let highlightedTextColor = assignable(name: "highlightedTextColor", type: UIColorPropertyType.self)
    public static let font = assignable(name: "font", type: Font.self)
    public static let numberOfLines = assignable(name: "numberOfLines", type: Int.self)
    public static let textAlignment = assignable(name: "textAlignment", type: TextAlignment.self)
    public static let isEnabled = assignable(name: "isEnabled", key: "enabled", type: Bool.self)
    public static let adjustsFontSizeToFitWidth = assignable(name: "adjustsFontSizeToFitWidth", type: Bool.self)
    public static let allowsDefaultTighteningBeforeTruncation = assignable(name: "allowsDefaultTighteningBeforeTruncation", type: Bool.self)
    public static let minimumScaleFactor = assignable(name: "minimumScaleFactor", type: Float.self)
    public static let isHighlighted = assignable(name: "isHighlighted", key: "highlighted", type: Bool.self)
    public static let shadowOffset = assignable(name: "shadowOffset", type: Size.self)
    public static let shadowColor = assignable(name: "shadowColor", type: UIColorPropertyType.self)
    public static let preferredMaxLayoutWidth = assignable(name: "preferredMaxLayoutWidth", type: Float.self)
    public static let lineBreakMode = assignable(name: "lineBreakMode", type: LineBreakMode.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            text,
            textColor,
            highlightedTextColor,
            font,
            numberOfLines,
            textAlignment,
            isEnabled,
            adjustsFontSizeToFitWidth,
            allowsDefaultTighteningBeforeTruncation,
            minimumScaleFactor,
            isHighlighted,
            shadowOffset,
            shadowColor,
            preferredMaxLayoutWidth,
            lineBreakMode,
        ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UILabel"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UILabel()
    }
    #endif
}
