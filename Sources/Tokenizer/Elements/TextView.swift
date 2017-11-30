//
//  TextView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class TextView: View {
    override class var availableProperties: [PropertyDescription] {
        return Properties.textView.allProperties
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

public class TextViewProperties: ViewProperties {
    public let text: AssignablePropertyDescription<TransformedText>
    public let font: AssignablePropertyDescription<Font>
    public let textColor: AssignablePropertyDescription<UIColorPropertyType>
    public let textAlignment: AssignablePropertyDescription<TextAlignment>
    public let textContainerInset: AssignablePropertyDescription<EdgeInsets>
    public let allowsEditingTextAttributes: AssignablePropertyDescription<Bool>
    
    public required init(configuration: Configuration) {
        text = configuration.property(name: "text")
        font = configuration.property(name: "font")
        textColor = configuration.property(name: "textColor")
        textAlignment = configuration.property(name: "textAlignment")
        textContainerInset = configuration.property(name: "textContainerInset")
        allowsEditingTextAttributes = configuration.property(name: "allowsEditingTextAttributes")
        
        super.init(configuration: configuration)
    }
}
