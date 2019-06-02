//
//  TextView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
    import UIKit
#endif
public class TextView: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.textView.allProperties
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return UITextView()
    }
    #endif
}

public class TextViewProperties: ViewProperties {
    public let text: AssignablePropertyDescription<TransformedText?>
    public let font: AssignablePropertyDescription<Font?>
    public let textColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let textAlignment: AssignablePropertyDescription<TextAlignment>
    public let textContainerInset: AssignablePropertyDescription<EdgeInsets>
    public let allowsEditingTextAttributes: AssignablePropertyDescription<Bool>
    
    public required init(configuration: Configuration) {
        text = configuration.property(name: "text", defaultValue: .text(""))
        font = configuration.property(name: "font")
        textColor = configuration.property(name: "textColor")
        textAlignment = configuration.property(name: "textAlignment", defaultValue: .natural)
        textContainerInset = configuration.property(name: "textContainerInset", defaultValue: EdgeInsets(horizontal: 0, vertical: 8))
        allowsEditingTextAttributes = configuration.property(name: "allowsEditingTextAttributes")
        
        super.init(configuration: configuration)
    }
}
