import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class TextView: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "text", type: TransformedText.self),
            assignable(name: "font", type: Font.self),
            assignable(name: "textColor", type: UIColorPropertyType.self),
            assignable(name: "textAlignment", type: TextAlignment.self),
            assignable(name: "textContainerInset", type: EdgeInsets.self),
            assignable(name: "allowsEditingTextAttributes", type: Bool.self),
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UITextView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UITextView()
    }
    #endif
}
