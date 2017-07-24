import Foundation

#if ReactantRuntime
import UIKit
#endif

public class Label: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "text", type: TransformedText.self),
            assignable(name: "textColor", type: UIColorPropertyType.self),
            assignable(name: "highlightedTextColor", type: UIColorPropertyType.self),
            assignable(name: "font", type: Font.self),
            assignable(name: "numberOfLines", type: Int.self),
            assignable(name: "textAlignment", type: TextAlignment.self),
            assignable(name: "isEnabled", key: "enabled", type: Bool.self),
            assignable(name: "adjustsFontSizeToFitWidth", type: Bool.self),
            assignable(name: "allowsDefaultTighteningBeforeTruncation", type: Bool.self),
            assignable(name: "minimumScaleFactor", type: Float.self),
            assignable(name: "isHighlighted", key: "highlighted", type: Bool.self),
            assignable(name: "shadowOffset", type: Size.self),
            assignable(name: "shadowColor", type: UIColorPropertyType.self),
            assignable(name: "preferredMaxLayoutWidth", type: Float.self),
            assignable(name: "lineBreakMode", type: LineBreakMode.self),
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
