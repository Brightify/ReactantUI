//
//  StackView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class StackView: Container {
    
    public override class var availableProperties: [PropertyDescription] {
        return Properties.stackView.allProperties
    }

    public override var addSubviewMethod: String {
        return "addArrangedSubview"
    }

    public class override func runtimeType() throws -> String {
        return "UIStackView"
    }

    public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
        return RuntimeType(name: "UIStackView", module: "UIKit")
    }

    #if canImport(UIKit)
    public override func add(subview: UIView, toInstanceOfSelf: UIView) {
        guard let stackView = toInstanceOfSelf as? UIStackView else {
            return super.add(subview: subview, toInstanceOfSelf: toInstanceOfSelf)
        }
        stackView.addArrangedSubview(subview)
    }
    #endif

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return UIStackView()
    }
    #endif
}

public class StackViewProperties: ViewProperties {
    public let axis: AssignablePropertyDescription<LayoutAxis>
    public let spacing: AssignablePropertyDescription<Double>
    public let distribution: AssignablePropertyDescription<LayoutDistribution>
    public let alignment: AssignablePropertyDescription<LayoutAlignment>
    public let isBaselineRelativeArrangement: AssignablePropertyDescription<Bool>
    public let isLayoutMarginsRelativeArrangement: AssignablePropertyDescription<Bool>
    
    public required init(configuration: Configuration) {
        axis = configuration.property(name: "axis", defaultValue: .horizontal)
        spacing = configuration.property(name: "spacing")
        distribution = configuration.property(name: "distribution", defaultValue: .fill)
        alignment = configuration.property(name: "alignment", defaultValue: .fill)
        isBaselineRelativeArrangement = configuration.property(name: "isBaselineRelativeArrangement", key: "baselineRelativeArrangement")
        isLayoutMarginsRelativeArrangement = configuration.property(name: "isLayoutMarginsRelativeArrangement", key: "layoutMarginsRelativeArrangement")
        
        super.init(configuration: configuration)
    }
}
