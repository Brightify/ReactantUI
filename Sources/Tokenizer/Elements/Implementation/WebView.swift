//
//  WebView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#if os(iOS)
import WebKit
#endif
import Hyperdrive
#endif

public class WebView: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.webView.allProperties
    }

    public override class var parentModuleImport: String {
        #if os(tvOS)
            return "UIKit"
        #else
            return "WebKit"
        #endif
    }

    public override var requiredImports: Set<String> {
        #if os(tvOS)
            return []
        #else
            return ["WebKit"]
        #endif
    }

    public class override func runtimeType() throws -> String {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: WebView.self)
        #else
            return "WKWebView"
        #endif
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
        #if os(tvOS)
            throw TokenizationError.unsupportedElementError(element: WebView.self)
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
