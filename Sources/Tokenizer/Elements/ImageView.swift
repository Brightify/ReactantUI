import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class ImageView: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "image", type: .image),
            assignable(name: "highlightedImage", type: .image),
            assignable(name: "animationDuration", type: .double),
            assignable(name: "animationRepeatCount", type: .integer),
            assignable(name: "isHighlighted", key: "highlighted", type: .bool),
            assignable(name: "adjustsImageWhenAncestorFocused", type: .bool),
        ] + super.availableProperties
    }

    public override var initialization: String {
        return "UIImageView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIImageView()
    }
    #endif
}
