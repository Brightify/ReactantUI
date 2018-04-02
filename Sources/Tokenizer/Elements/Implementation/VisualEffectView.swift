//
//  VisualEffectView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public class VisualEffectView: Container {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.visualEffectView.allProperties
    }

    public override var addSubviewMethod: String {
        return "contentView.addSubview"
    }

    public class override func runtimeType() -> String {
        return "UIVisualEffectView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIVisualEffectView()
    }

    public override func add(subview: UIView, toInstanceOfSelf: UIView) {
        guard let visualEffectView = toInstanceOfSelf as? UIVisualEffectView else {
            return super.add(subview: subview, toInstanceOfSelf: toInstanceOfSelf)
        }
        visualEffectView.contentView.addSubview(subview)
    }
    #endif
}

public class VisualEffectViewProperties: ViewProperties {
    public let effect: AssignablePropertyDescription<VisualEffect>
    
    public required init(configuration: Configuration) {
        effect = configuration.property(name: "effect")
        
        super.init(configuration: configuration)
    }
}

