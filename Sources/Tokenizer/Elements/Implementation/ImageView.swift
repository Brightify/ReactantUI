//
//  ImageView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

public class ImageView: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.imageView.allProperties
    }

    public class override func runtimeType() -> String {
        return "UIImageView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIImageView()
    }
    #endif
}

public class ImageViewProperties: ViewProperties {
    public let image: AssignablePropertyDescription<Image>
    public let highlightedImage: AssignablePropertyDescription<Image>
    public let animationDuration: AssignablePropertyDescription<Double>
    public let animationRepeatCount: AssignablePropertyDescription<Int>
    public let isHighlighted: AssignablePropertyDescription<Bool>
    public let adjustsImageWhenAncestorFocused: AssignablePropertyDescription<Bool>
    
    public required init(configuration: Configuration) {
        image = configuration.property(name: "image")
        highlightedImage = configuration.property(name: "highlightedImage")
        animationDuration = configuration.property(name: "animationDuration")
        animationRepeatCount = configuration.property(name: "animationRepeatCount")
        isHighlighted = configuration.property(name: "isHighlighted", key: "highlighted")
        adjustsImageWhenAncestorFocused = configuration.property(name: "adjustsImageWhenAncestorFocused")
        
        super.init(configuration: configuration)
    }
}
