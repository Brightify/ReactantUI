import Foundation

#if ReactantRuntime
import UIKit
#endif

public class Label: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "text", type: .string),
            assignable(name: "textColor", type: .color(.uiColor)),
            assignable(name: "highlightedTextColor", type: .color(.uiColor)),
            assignable(name: "font", type: .font),
            assignable(name: "numberOfLines", type: .integer),
            assignable(name: "textAlignment", type: .textAlignment),
            assignable(name: "isEnabled", key: "enabled", type: .bool),
            assignable(name: "adjustsFontSizeToFitWidth", type: .bool),
            assignable(name: "allowsDefaultTighteningBeforeTruncation", type: .bool),
            assignable(name: "minimumScaleFactor", type: .float),
            assignable(name: "isHighlighted", key: "highlighted", type: .bool),
            assignable(name: "shadowOffset", type: .size),
            assignable(name: "shadowColor", type: .color(.uiColor)),
            assignable(name: "preferredMaxLayoutWidth", type: .float),
            assignable(name: "lineBreakMode", type: .lineBreakMode),
        ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UILabel"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UILabel()
    }

    override class func placeholderProperties() -> [(description: PropertyDescription, value: String)] {
        return [(assignable(name: "text", type: .string), "<< Label >>")]
    }
    #endif
}
