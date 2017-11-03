//
//  PickerView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

// TODO might be replaced with our generic implementation
public class PickerView: View {
    override class var availableProperties: [PropertyDescription] {
        return Properties.pickerView.allProperties
    }

    public class override var runtimeType: String {
        #if os(tvOS)
            return "UIView"
        #else
            return "UIPickerView"
        #endif
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        #if os(tvOS)
            return UIView()
        #else
            return UIPickerView()
        #endif
    }
    #endif
}

public class PickerViewProperties: ViewProperties {
    public required init(configuration: Configuration) {
        
        super.init(configuration: configuration)
    }
}
