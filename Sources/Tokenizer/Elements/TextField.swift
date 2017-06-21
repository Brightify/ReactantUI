import Foundation

#if ReactantRuntime
import UIKit
import Reactant
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
            assignable(name: "contentEdgeInsets", type: .edgeInsets),
            assignable(name: "placeholderColor", type: .color(.uiColor)),
            assignable(name: "placeholderFont", type: .font),
            assignable(name: "secure", swiftName: "isSecureTextEntry", key: "secureTextEntry", type: .bool),
            assignable(name: "keyboardType", type: .keyboardType),
            assignable(name: "keyboardAppearance", type: .keyboardAppearance),
            assignable(name: "contentType", type: .textContentType),
            assignable(name: "returnKey", type: .returnKeyType),
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "Reactant.TextField"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return Reactant.TextField()
    }
    #endif
}
