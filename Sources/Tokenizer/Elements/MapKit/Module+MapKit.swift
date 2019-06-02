//
//  Module+MapKit.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import Foundation

extension Module {
    public static let mapKit = MapKit()

    public struct MapKit: RuntimeModule {
        public struct iOS { }
        public struct macOS { }

        public let supportedPlatforms: Set<RuntimePlatform> = [
            .iOS,
        ]

        public func elements(for platform: RuntimePlatform) -> [UIElementFactory] {
            return [
                factory(named: "MapView", for: iOS.MapView.init),
            ]
        }
    }
}
