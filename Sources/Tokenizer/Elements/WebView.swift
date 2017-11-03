//
//  WebView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#if os(iOS)
    import WebKit
#endif
    import Reactant
#endif

public class WebView: View {
    override class var availableProperties: [PropertyDescription] {
        return Properties.webView.allProperties
    }

    public override var requiredImports: Set<String> {
        #if os(tvOS)
            return []
        #else
            return ["WebKit"]
        #endif
    }

    public class override var runtimeType: String {
        #if os(tvOS)
            return "UIView"
        #else
            return "WKWebView"
        #endif
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        #if os(tvOS)
            return UIView()
        #else
            return WKWebView()
        #endif
    }
    #endif
}

public class WebViewProperties: ViewProperties {
    public let allowsMagnification: AssignablePropertyDescription<Bool>
    public let magnification: AssignablePropertyDescription<Float>
    public let allowsBackForwardNavigationGestures: AssignablePropertyDescription<Bool>
    
    public required init(configuration: Configuration) {
        allowsMagnification = configuration.property(name: "allowsMagnification")
        magnification = configuration.property(name: "magnification")
        allowsBackForwardNavigationGestures = configuration.property(name: "allowsBackForwardNavigationGestures")
        
        super.init(configuration: configuration)
    }
}
