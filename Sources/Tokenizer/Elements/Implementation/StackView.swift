//
//  StackView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public class StackView: Container {
    
    public override class var availableProperties: [PropertyDescription] {
        return Properties.stackView.allProperties
    }

    public override var addSubviewMethod: String {
        return "addArrangedSubview"
    }

    #if ReactantRuntime
    public override func add(subview: UIView, toInstanceOfSelf: UIView) {
        guard let stackView = toInstanceOfSelf as? UIStackView else {
            return super.add(subview: subview, toInstanceOfSelf: toInstanceOfSelf)
        }
        stackView.addArrangedSubview(subview)
    }
    #endif

    public class override var runtimeType: String {
        return "UIStackView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIStackView()
    }
    #endif
}

public class StackViewProperties: ViewProperties {
    public let axis: AssignablePropertyDescription<LayoutAxis>
    public let spacing: AssignablePropertyDescription<Float>
    public let distribution: AssignablePropertyDescription<LayoutDistribution>
    public let alignment: AssignablePropertyDescription<LayoutAlignment>
    public let isBaselineRelativeArrangement: AssignablePropertyDescription<Bool>
    public let isLayoutMarginsRelativeArrangement: AssignablePropertyDescription<Bool>
    
    public required init(configuration: Configuration) {
        axis = configuration.property(name: "axis")
        spacing = configuration.property(name: "spacing")
        distribution = configuration.property(name: "distribution")
        alignment = configuration.property(name: "alignment")
        isBaselineRelativeArrangement = configuration.property(name: "isBaselineRelativeArrangement", key: "baselineRelativeArrangement")
        isLayoutMarginsRelativeArrangement = configuration.property(name: "isLayoutMarginsRelativeArrangement", key: "layoutMarginsRelativeArrangement")
        
        super.init(configuration: configuration)
    }
}
