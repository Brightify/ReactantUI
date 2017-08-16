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
            + nested(field: "imageView", namespace: "imageView", optional: true, properties: ImageView.availableProperties)

    }
    
    struct TitleLabel: NestedPropertyContainer {
        public static let namespace: String = "titleLabel"
        
        public static let text = nested(Label.text)
        public static let textColor = nested(Label.textColor)
        public static let highlightedTextColor = nested(Label.highlightedTextColor)
        public static let font = nested(Label.font)
        public static let numberOfLines = nested(Label.numberOfLines)
        public static let textAlignment = nested(Label.textAlignment)
        public static let isEnabled = nested(Label.isEnabled)
        public static let adjustsFontSizeToFitWidth = nested(Label.adjustsFontSizeToFitWidth)
        public static let allowsDefaultTighteningBeforeTruncation = nested(Label.allowsDefaultTighteningBeforeTruncation)
        public static let minimumScaleFactor = nested(Label.minimumScaleFactor)
        public static let isHighlighted = nested(Label.isHighlighted)
        public static let shadowOffset = nested(Label.shadowOffset)
        public static let shadowColor = nested(Label.shadowColor)
        public static let preferredMaxLayoutWidth = nested(Label.preferredMaxLayoutWidth)
        public static let lineBreakMode = nested(Label.lineBreakMode)
    }
    
    public struct ImageViewProperties: NestedPropertyContainer {
        public static let namespace: String = "imageView"
        
        public static let image = nested(ImageView.image)
        public static let highlightedImage = nested(ImageView.highlightedImage)
        public static let animationDuration = nested(ImageView.animationDuration)
        public static let animationRepeatCount = nested(ImageView.animationRepeatCount)
        public static let isHighlighted = nested(ImageView.isHighlighted)
        public static let adjustsImageWhenAncestorFocused = nested(ImageView.adjustsImageWhenAncestorFocused)
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
