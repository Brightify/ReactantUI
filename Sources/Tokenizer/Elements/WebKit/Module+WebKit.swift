//
//  Module+WebKit.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import Foundation

extension Module {
    static let webKit = WebKit()

    struct WebKit: RuntimeModule {
        let supportedPlatforms: Set<RuntimePlatform> = [
            .iOS,
        ]

        func elements(for platform: RuntimePlatform) -> [UIElementFactory] {
            return [
                factory(named: "WebView", for: WebView.init),
            ]
        }
    }
}
