//
//  Toolbar.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class Toolbar: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.toolbar.allProperties
    }

    public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
        switch platform {
        case .iOS:
            return RuntimeType(name: "UIToolbar", module: "UIKit")
        case .tvOS:
            fatalError("View not available in tvOS")
        }
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        #if os(tvOS)
            fatalError("View not available in tvOS")
        #else
            return UIToolbar()
        #endif
    }
    #endif
}

public class ToolbarProperties: ViewProperties {
    public let isTranslucent: AssignablePropertyDescription<Bool>
    public let barStyle: AssignablePropertyDescription<BarStyle>
    public let barTintColor: AssignablePropertyDescription<UIColorPropertyType?>
    
    public required init(configuration: Configuration) {
        isTranslucent = configuration.property(name: "isTranslucent", key: "translucent", defaultValue: true)
        barStyle = configuration.property(name: "barStyle", defaultValue: .default)
        barTintColor = configuration.property(name: "barTintColor")
        
        super.init(configuration: configuration)
    }
}
