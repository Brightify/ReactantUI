//
//  PickerView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

// TODO might be replaced with our generic implementation
public class PickerView: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.pickerView.allProperties
    }

    public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
        switch platform {
        case .iOS:
            return RuntimeType(name: "UIPickerView", module: "UIKit")
        case .tvOS:
            throw TokenizationError.unsupportedElementError(element: PickerView.self)
        }
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: PickerView.self)
        #else
            return UIPickerView()
        #endif
    }
    #endif
}

public class PickerViewProperties: ControlProperties {
    public required init(configuration: Configuration) {
        
        super.init(configuration: configuration)
    }
}
