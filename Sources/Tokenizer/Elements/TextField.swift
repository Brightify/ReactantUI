import Foundation

#if ReactantRuntime
import UIKit
import Reactant
#endif

public class TextField: View {
    public static let text = assignable(name: "text", type: TransformedText.self)
    public static let placeholder = assignable(name: "placeholder", type: TransformedText.self)
    public static let font = assignable(name: "font", type: Font.self)
    public static let textColor = assignable(name: "textColor", type: UIColorPropertyType.self)
    public static let textAlignment = assignable(name: "textAlignment", type: TextAlignment.self)
    public static let adjustsFontSizeToWidth = assignable(name: "adjustsFontSizeToWidth", type: Bool.self)
    public static let minimumFontSize = assignable(name: "minimumFontSize", type: Float.self)
    public static let clearsOnBeginEditing = assignable(name: "clearsOnBeginEditing", type: Bool.self)
    public static let clearsOnInsertion = assignable(name: "clearsOnInsertion", type: Bool.self)
    public static let allowsEditingTextAttributes = assignable(name: "allowsEditingTextAttributes", type: Bool.self)
    public static let background = assignable(name: "background", type: Image.self)
    public static let disabledBackground = assignable(name: "disabledBackground", type: Image.self)
    public static let borderStyle = assignable(name: "borderStyle", type: TextBorderStyle.self)
    public static let clearButtonMode = assignable(name: "clearButtonMode", type: TextFieldViewMode.self)
    public static let leftViewMode = assignable(name: "leftViewMode", type: TextFieldViewMode.self)
    public static let rightViewMode = assignable(name: "rightViewMode", type: TextFieldViewMode.self)
    public static let contentEdgeInsets = assignable(name: "contentEdgeInsets", type: EdgeInsets.self)
    public static let placeholderColor = assignable(name: "placeholderColor", type: UIColorPropertyType.self)
    public static let placeholderFont = assignable(name: "placeholderFont", type: Font.self)
    public static let isSecureTextEntry = assignable(name: "secure", swiftName: "isSecureTextEntry", key: "secureTextEntry", type: Bool.self)
    public static let keyboardType = assignable(name: "keyboardType", type: KeyboardType.self)
    public static let keyboardAppearance = assignable(name: "keyboardAppearance", type: KeyboardAppearance.self)
    public static let contentType = assignable(name: "contentType", type: TextContentType.self)
    public static let returnKey = assignable(name: "returnKey", type: ReturnKeyType.self)

    override class var availableProperties: [PropertyDescription] {
        return [
            text,
            placeholder,
            font,
            textColor,
            textAlignment,
            adjustsFontSizeToWidth,
            minimumFontSize,
            clearsOnBeginEditing,
            clearsOnInsertion,
            allowsEditingTextAttributes,
            background,
            disabledBackground,
            borderStyle,
            clearButtonMode,
            leftViewMode,
            rightViewMode,
            contentEdgeInsets,
            placeholderColor,
            placeholderFont,
            isSecureTextEntry,
            keyboardType,
            keyboardAppearance,
            contentType,
            returnKey,
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
