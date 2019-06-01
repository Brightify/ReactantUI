//
//  TextField.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
import Hyperdrive
#endif

public class TextField: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.textField.allProperties
    }

    public override class var parentModuleImport: String {
        return "Hyperdrive"
    }

    public class override func runtimeType() -> String {
        return "Hyperdrive.TextField"
    }
    
    public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
        return RuntimeType(name: "TextField", module: "Hyperdrive")
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return Hyperdrive.TextField()
    }
    #endif
}

public class TextFieldProperties: ControlProperties {
    public let text: AssignablePropertyDescription<TransformedText?>
    public let placeholder: AssignablePropertyDescription<TransformedText?>
    public let font: AssignablePropertyDescription<Font?>
    public let textColor: AssignablePropertyDescription<UIColorPropertyType>
    public let textAlignment: AssignablePropertyDescription<TextAlignment>
    public let adjustsFontSizeToWidth: AssignablePropertyDescription<Bool>
    public let minimumFontSize: AssignablePropertyDescription<Float>
    public let clearsOnBeginEditing: AssignablePropertyDescription<Bool>
    public let clearsOnInsertion: AssignablePropertyDescription<Bool>
    public let allowsEditingTextAttributes: AssignablePropertyDescription<Bool>
    public let background: AssignablePropertyDescription<Image?>
    public let disabledBackground: AssignablePropertyDescription<Image?>
    public let borderStyle: AssignablePropertyDescription<TextBorderStyle>
    public let clearButtonMode: AssignablePropertyDescription<TextFieldViewMode>
    public let leftViewMode: AssignablePropertyDescription<TextFieldViewMode>
    public let rightViewMode: AssignablePropertyDescription<TextFieldViewMode>
    public let contentEdgeInsets: AssignablePropertyDescription<EdgeInsets>
    public let placeholderColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let placeholderFont: AssignablePropertyDescription<Font?>
    public let isSecureTextEntry: AssignablePropertyDescription<Bool>
    public let keyboardType: AssignablePropertyDescription<KeyboardType>
    public let keyboardAppearance: AssignablePropertyDescription<KeyboardAppearance>
    public let contentType: AssignablePropertyDescription<TextContentType?>
    public let returnKey: AssignablePropertyDescription<ReturnKeyType>

    public let enablesReturnKeyAutomatically: AssignablePropertyDescription<Bool>
    public let autocapitalizationType: AssignablePropertyDescription<AutocapitalizationType>
    public let autocorrectionType: AssignablePropertyDescription<AutocorrectionType>
    public let spellCheckingType: AssignablePropertyDescription<SpellCheckingType>
    public let smartQuotesType: AssignablePropertyDescription<SmartQuotesType>
    public let smartDashesType: AssignablePropertyDescription<SmartDashesType>
    public let smartInsertDeleteType: AssignablePropertyDescription<SmartInsertDeleteType>
    
    public required init(configuration: Configuration) {
        text = configuration.property(name: "text", defaultValue: .text(""))
        placeholder = configuration.property(name: "placeholder")
        font = configuration.property(name: "font")
        textColor = configuration.property(name: "textColor", defaultValue: .black)
        textAlignment = configuration.property(name: "textAlignment", defaultValue: .natural)
        adjustsFontSizeToWidth = configuration.property(name: "adjustsFontSizeToWidth")
        minimumFontSize = configuration.property(name: "minimumFontSize", defaultValue: 0)
        clearsOnBeginEditing = configuration.property(name: "clearsOnBeginEditing")
        clearsOnInsertion = configuration.property(name: "clearsOnInsertion")
        allowsEditingTextAttributes = configuration.property(name: "allowsEditingTextAttributes")
        background = configuration.property(name: "background")
        disabledBackground = configuration.property(name: "disabledBackground")
        borderStyle = configuration.property(name: "borderStyle", defaultValue: .none)
        clearButtonMode = configuration.property(name: "clearButtonMode", defaultValue: .never)
        leftViewMode = configuration.property(name: "leftViewMode", defaultValue: .never)
        rightViewMode = configuration.property(name: "rightViewMode", defaultValue: .never)
        contentEdgeInsets = configuration.property(name: "contentEdgeInsets")
        placeholderColor = configuration.property(name: "placeholderColor")
        placeholderFont = configuration.property(name: "placeholderFont")
        isSecureTextEntry = configuration.property(name: "secure", swiftName: "isSecureTextEntry", key: "secureTextEntry")
        keyboardType = configuration.property(name: "keyboardType", defaultValue: .default)
        keyboardAppearance = configuration.property(name: "keyboardAppearance", defaultValue: .default)
        contentType = configuration.property(name: "contentType")
        returnKey = configuration.property(name: "returnKey", defaultValue: .default)
        enablesReturnKeyAutomatically = configuration.property(name: "enablesReturnKeyAutomatically")
        autocapitalizationType = configuration.property(name: "autocapitalizationType", defaultValue: .sentences)
        autocorrectionType = configuration.property(name: "autocorrectionType", defaultValue: .default)
        spellCheckingType = configuration.property(name: "spellCheckingType", defaultValue: .default)
        smartQuotesType = configuration.property(name: "smartQuotesType", defaultValue: .default)
        smartDashesType = configuration.property(name: "smartDashesType", defaultValue: .default)
        smartInsertDeleteType = configuration.property(name: "smartInsertDeleteType", defaultValue: .default)
        
        super.init(configuration: configuration)
    }
    
}

