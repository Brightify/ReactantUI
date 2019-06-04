//
//  Module+WebKit.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import Foundation

extension Module {
    public static let webKit = WebKit()

    public struct WebKit: RuntimeModule {
        public let supportedPlatforms: Set<RuntimePlatform> = [
            .iOS,
        ]

        public func elements(for platform: RuntimePlatform) -> [UIElementFactory] {
            return [
                factory(named: "WebView", for: WebView.init),
            ]
        }
    }
}
