//
//  Label.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class Label: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.label.allProperties
    }

    public class override func runtimeType() -> String {
        return "UILabel"
    }

    #if canImport(UIKit)
    public override func initialize() -> UIView {
        return UILabel()
    }
    #endif
}

public class LabelProperties: ViewProperties {
    public let text: AssignablePropertyDescription<TransformedText>
    public let textColor: AssignablePropertyDescription<UIColorPropertyType>
    public let highlightedTextColor: AssignablePropertyDescription<UIColorPropertyType>
    public let font: AssignablePropertyDescription<Font>
    public let numberOfLines: AssignablePropertyDescription<Int>
    public let textAlignment: AssignablePropertyDescription<TextAlignment>
    public let isEnabled: AssignablePropertyDescription<Bool>
    public let adjustsFontSizeToFitWidth: AssignablePropertyDescription<Bool>
    public let allowsDefaultTighteningBeforeTruncation: AssignablePropertyDescription<Bool>
    public let minimumScaleFactor: AssignablePropertyDescription<Float>
    public let isHighlighted: AssignablePropertyDescription<Bool>
    public let shadowOffset: AssignablePropertyDescription<Size>
    public let shadowColor: AssignablePropertyDescription<UIColorPropertyType>
    public let preferredMaxLayoutWidth: AssignablePropertyDescription<Float>
    public let lineBreakMode: AssignablePropertyDescription<LineBreakMode>
    public let attributedText: ElementAssignablePropertyDescription<AttributedText>
    
    public required init(configuration: Configuration) {
        text = configuration.property(name: "text")
        textColor = configuration.property(name: "textColor")
        highlightedTextColor = configuration.property(name: "highlightedTextColor")
        font = configuration.property(name: "font")
        numberOfLines = configuration.property(name: "numberOfLines")
        textAlignment = configuration.property(name: "textAlignment")
        isEnabled = configuration.property(name: "isEnabled", key: "enabled")
        adjustsFontSizeToFitWidth = configuration.property(name: "adjustsFontSizeToFitWidth")
        allowsDefaultTighteningBeforeTruncation = configuration.property(name: "allowsDefaultTighteningBeforeTruncation")
        minimumScaleFactor = configuration.property(name: "minimumScaleFactor")
        isHighlighted = configuration.property(name: "isHighlighted", key: "highlighted")
        shadowOffset = configuration.property(name: "shadowOffset")
        shadowColor = configuration.property(name: "shadowColor")
        preferredMaxLayoutWidth = configuration.property(name: "preferredMaxLayoutWidth")
        lineBreakMode = configuration.property(name: "lineBreakMode")
        attributedText = configuration.property(name: "attributedText")
        
        super.init(configuration: configuration)
    }
}
