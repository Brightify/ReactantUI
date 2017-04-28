import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class Button: Container {
    override class var availableProperties: [PropertyDescription] {
        return [
            controlState(name: "title", type: .string),
            controlState(name: "titleColor", type: .color(.uiColor)),
            controlState(name: "backgroundColor", type: .color(.uiColor)),
            controlState(name: "titleShadowColor", type: .color(.uiColor)),
            controlState(name: "image", type: .image),
            controlState(name: "backgroundImage", type: .image),
            assignable(name: "reversesTitleShadowWhenHighlighted", type: .bool),
            assignable(name: "adjustsImageWhenHighlighted", type: .bool),
            assignable(name: "adjustsImageWhenDisabled", type: .bool),
            assignable(name: "showsTouchWhenHighlighted", type: .bool),
            assignable(name: "contentEdgeInsets", type: .edgeInsets),
            assignable(name: "titleEdgeInsets", type: .edgeInsets),
            assignable(name: "imageEdgeInsets", type: .edgeInsets),
        ] + super.availableProperties
            + nested(field: "titleLabel", namespace: "titleLabel", optional: true, properties: Label.availableProperties)
            + nested(field: "imageView", namespace: "imageView", optional: true, properties: Label.availableProperties)

    }

    public override var initialization: String {
        return "UIButton()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIButton()
    }
    #endif
}
