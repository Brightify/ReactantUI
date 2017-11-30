//
//  SegmentedControl.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

// TODO add a way of adding segments
public class SegmentedControl: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.segmentedControl.allProperties
    }

    public class override var runtimeType: String {
        return "UISegmentedControl"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UISegmentedControl()
    }
    #endif
}

public class SegmentedControlProperties: ViewProperties {
    public let selectedSegmentIndex: AssignablePropertyDescription<Int>
    public let isMomentary: AssignablePropertyDescription<Bool>
    public let apportionsSegmentWidthsByContent: AssignablePropertyDescription<Bool>
    
    public required init(configuration: Configuration) {
        selectedSegmentIndex = configuration.property(name: "selectedSegmentIndex")
        isMomentary = configuration.property(name: "isMomentary")
        apportionsSegmentWidthsByContent = configuration.property(name: "apportionsSegmentWidthsByContent")
        
        super.init(configuration: configuration)
    }
}
    
