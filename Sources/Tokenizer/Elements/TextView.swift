import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class TextView: View {
    
    public static let text = assignable(name: "text", type: TransformedText.self)
    public static let font = assignable(name: "font", type: Font.self)
    public static let textColor = assignable(name: "textColor", type: UIColorPropertyType.self)
    public static let textAlignment = assignable(name: "textAlignment", type: TextAlignment.self)
    public static let textContainerInset = assignable(name: "textContainerInset", type: EdgeInsets.self)
    public static let allowsEditingTextAttributes = assignable(name: "allowsEditingTextAttributes", type: Bool.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            text,
            font,
            textColor,
            textAlignment,
            textContainerInset,
            allowsEditingTextAttributes,
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
