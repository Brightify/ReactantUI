import Foundation

#if ReactantRuntime
import UIKit
#endif

public class Button: Container {
    public static let title = controlState(name: "title", type: TransformedText.self)
    public static let titleColor = controlState(name: "titleColor", type: UIColorPropertyType.self)
    public static let backgroundColorForState = controlState(name: "backgroundColor", type: UIColorPropertyType.self)
    public static let titleShadowColor = controlState(name: "titleShadowColor", type: UIColorPropertyType.self)
    public static let image = controlState(name: "image", type: Image.self)
    public static let backgroundImage = controlState(name: "backgroundImage", type: Image.self)
    public static let reversesTitleShadowWhenHighlighted = assignable(name: "reversesTitleShadowWhenHighlighted", type: Bool.self)
    public static let adjustsImageWhenHighlighted = assignable(name: "adjustsImageWhenHighlighted", type: Bool.self)
    public static let adjustsImageWhenDisabled = assignable(name: "adjustsImageWhenDisabled", type: Bool.self)
    public static let showsTouchWhenHighlighted = assignable(name: "showsTouchWhenHighlighted", type: Bool.self)
    public static let contentEdgeInsets = assignable(name: "contentEdgeInsets", type: EdgeInsets.self)
    public static let titleEdgeInsets = assignable(name: "titleEdgeInsets", type: EdgeInsets.self)
    public static let imageEdgeInsets = assignable(name: "imageEdgeInsets", type: EdgeInsets.self)

    override class var availableProperties: [PropertyDescription] {
        return [
            title,
            titleColor,
            backgroundColorForState,
            titleShadowColor,
            image,
            backgroundImage,
            reversesTitleShadowWhenHighlighted,
            adjustsImageWhenHighlighted,
            adjustsImageWhenDisabled,
            showsTouchWhenHighlighted,
            contentEdgeInsets,
            titleEdgeInsets,
            imageEdgeInsets,
        ] + super.availableProperties
            + nested(field: "titleLabel", namespace: "titleLabel", optional: true, properties: Label.availableProperties)
            + nested(field: "imageView", namespace: "imageView", optional: true, properties: Label.availableProperties)

    }

    public class override var runtimeType: String {
        return "UIButton"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIButton()
    }
    #endif
}
