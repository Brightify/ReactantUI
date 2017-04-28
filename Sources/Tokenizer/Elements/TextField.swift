import Foundation
import SWXMLHash
#if ReactantRuntime
import UIKit
#endif

public class TextField: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "text", type: .string),
            assignable(name: "placeholder", type: .string),
            assignable(name: "font", type: .font),
            assignable(name: "textColor", type: .color(.uiColor)),
            assignable(name: "textAlignment", type: .textAlignment),
            assignable(name: "adjustsFontSizeToWidth", type: .bool),
            assignable(name: "minimumFontSize", type: .float),
            assignable(name: "clearsOnBeginEditing", type: .bool),
            assignable(name: "clearsOnInsertion", type: .bool),
            assignable(name: "allowsEditingTextAttributes", type: .bool),
            assignable(name: "background", type: .image),
            assignable(name: "disabledBackground", type: .image),
            assignable(name: "borderStyle", type: .textBorderStyle),
            assignable(name: "clearButtonMode", type: .textFieldViewMode),
            assignable(name: "leftViewMode", type: .textFieldViewMode),
            assignable(name: "rightViewMode", type: .textFieldViewMode),
            ] + super.availableProperties
    }

    public override var initialization: String {
        return "UITextField()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UITextField()
    }
    #endif
}
