//
//  ProgressView.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 16/04/2018.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class ProgressView: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.progressView.allProperties
    }

    public class override func runtimeType() -> String {
        return "UIProgressView"
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
        return UIProgressView()
    }
    #endif
}

public class ProgressViewProperties: ViewProperties {
    public let progress: AssignablePropertyDescription<Float>
    public let progressViewStyle: AssignablePropertyDescription<ProgressViewStyle>
    public let progressTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let progressImage: AssignablePropertyDescription<Image>
    public let trackTintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let trackImage: AssignablePropertyDescription<Image>

    public required init(configuration: Configuration) {
        progress = configuration.property(name: "progress")
        progressViewStyle = configuration.property(name: "progressViewStyle")
        progressTintColor = configuration.property(name: "progressTintColor")
        progressImage = configuration.property(name: "progressImage")
        trackTintColor = configuration.property(name: "trackTintColor")
        trackImage = configuration.property(name: "trackImage")

        super.init(configuration: configuration)
    }
}
