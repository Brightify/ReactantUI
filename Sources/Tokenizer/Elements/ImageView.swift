import Foundation

#if ReactantRuntime
import UIKit
#endif

public struct Image: SupportedPropertyType {
    public let name: String

    public var generated: String {
        return "UIImage(named: \"\(name)\")"
    }

    #if ReactantRuntime
    public var runtimeValue: Any? {
        return UIImage(named: name)
    }
    #endif
    
    #if SanAndreas
    public func dematerialize() -> String {
    return name
    }
    #endif

    public init(named name: String) {
        self.name = name
    }

    public static func materialize(from value: String) throws -> Image {
        return Image(named: value)
    }
}

public class ImageView: View {
    public static let image = assignable(name: "image", type: Image.self)
    public static let highlightedImage = assignable(name: "highlightedImage", type: Image.self)
    public static let animationDuration = assignable(name: "animationDuration", type: Double.self)
    public static let animationRepeatCount = assignable(name: "animationRepeatCount", type: Int.self)
    public static let isHighlighted = assignable(name: "isHighlighted", key: "highlighted", type: Bool.self)
    public static let adjustsImageWhenAncestorFocused = assignable(name: "adjustsImageWhenAncestorFocused", type: Bool.self)
    override class var availableProperties: [PropertyDescription] {
        return [
            image,
            highlightedImage,
            animationDuration,
            animationRepeatCount,
            isHighlighted,
            adjustsImageWhenAncestorFocused,
        ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UIImageView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIImageView()
    }
    #endif
}
