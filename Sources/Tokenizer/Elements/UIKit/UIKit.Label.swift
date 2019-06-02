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

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return UILabel()
    }
    #endif
}

public class LabelProperties: ViewProperties {
    public let text: AssignablePropertyDescription<TransformedText?>
    public let textColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let highlightedTextColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let font: AssignablePropertyDescription<Font?>
    public let numberOfLines: AssignablePropertyDescription<Int>
    public let textAlignment: AssignablePropertyDescription<TextAlignment>
    public let isEnabled: AssignablePropertyDescription<Bool>
    public let adjustsFontSizeToFitWidth: AssignablePropertyDescription<Bool>
    public let allowsDefaultTighteningForTruncation: AssignablePropertyDescription<Bool>
    public let minimumScaleFactor: AssignablePropertyDescription<Double>
    public let isHighlighted: AssignablePropertyDescription<Bool>
    public let shadowOffset: AssignablePropertyDescription<Size>
    public let shadowColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let preferredMaxLayoutWidth: AssignablePropertyDescription<Double>
    public let lineBreakMode: AssignablePropertyDescription<LineBreakMode>
    public let attributedText: ElementAssignablePropertyDescription<AttributedText?>
    
    public required init(configuration: Configuration) {
        text = configuration.property(name: "text")
        textColor = configuration.property(name: "textColor")
        highlightedTextColor = configuration.property(name: "highlightedTextColor")
        font = configuration.property(name: "font")
        numberOfLines = configuration.property(name: "numberOfLines", defaultValue: 1)
        textAlignment = configuration.property(name: "textAlignment", defaultValue: .natural)
        isEnabled = configuration.property(name: "isEnabled", key: "enabled", defaultValue: true)
        adjustsFontSizeToFitWidth = configuration.property(name: "adjustsFontSizeToFitWidth")
        allowsDefaultTighteningForTruncation = configuration.property(name: "allowsDefaultTighteningForTruncation")
        minimumScaleFactor = configuration.property(name: "minimumScaleFactor")
        isHighlighted = configuration.property(name: "isHighlighted", key: "highlighted")
        shadowOffset = configuration.property(name: "shadowOffset", defaultValue: Size(width: 0, height: -1))
        shadowColor = configuration.property(name: "shadowColor")
        preferredMaxLayoutWidth = configuration.property(name: "preferredMaxLayoutWidth")
        lineBreakMode = configuration.property(name: "lineBreakMode", defaultValue: .byTruncatingTail)
        attributedText = configuration.property(name: "attributedText")
        
        super.init(configuration: configuration)
    }
}
