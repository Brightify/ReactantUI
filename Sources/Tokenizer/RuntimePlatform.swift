//
//  RuntimePlatform.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import Foundation

public enum RuntimePlatform: CustomStringConvertible, CaseIterable {
    case iOS
    //    case macOS
    case tvOS

    public var description: String {
        switch self {
        case .iOS:
            return "Support for iOS views."
        case .tvOS:
            return "Support for tvOS views."
        }
    }

    public var supportedTypes: [SupportedPropertyType.Type] {
        let commonTypes: [SupportedPropertyType.Type] = [
            TransformedText.self,
            Double.self,
            Int.self,
            Float.self,
            Bool.self,

        ]

        let platformTypes: [SupportedPropertyType.Type]
        switch self {
        case .iOS, .tvOS:
            platformTypes = [
                UIColorPropertyType.self,
                CGColorPropertyType.self
            ]
        }

        return platformTypes + commonTypes
    }
}
