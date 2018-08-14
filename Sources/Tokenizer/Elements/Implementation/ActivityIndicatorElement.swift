//
//  ActivityIndicatorElement.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class ActivityIndicatorElement: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.activityIndicator.allProperties
    }

    public static var defaultContentHugging: (horizontal: ConstraintPriority, vertical: ConstraintPriority) {
        return (.high, .high)
    }

    public class override func runtimeType() throws -> String {
        return "UIActivityIndicatorView"
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return UIActivityIndicatorView()
    }
    #endif
}

public class ActivityIndicatorProperties: ViewProperties {
    public let color: AssignablePropertyDescription<UIColorPropertyType>
    public let hidesWhenStopped: AssignablePropertyDescription<Bool>
    public let indicatorStyle: AssignablePropertyDescription<ActivityIndicatorStyle>
    
    public required init(configuration: PropertyContainer.Configuration) {
        color = configuration.property(name: "color")
        hidesWhenStopped = configuration.property(name: "hidesWhenStopped")
        indicatorStyle = configuration.property(name: "indicatorStyle", swiftName: "activityIndicatorViewStyle", key: "activityIndicatorViewStyle")
        
        super.init(configuration: configuration)
    }
}
