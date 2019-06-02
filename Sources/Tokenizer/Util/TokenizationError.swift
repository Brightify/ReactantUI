//
//  TokenizationError.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct TokenizationError: Error, LocalizedError {
    public let message: String

    public var localizedDescription: String {
        return message
    }

    public var errorDescription: String? {
        return message
    }

    public init(message: String) {
        self.message = message
    }
}

extension TokenizationError {
    public static func unsupportedElementError(element: View.Type) -> TokenizationError {
//        let name = ElementMapping.mapping.first(where: { $1 == element })?.key ?? "(unknown - \(element)"
        return TokenizationError(message: "Element \(element) is unavailable on this platform.")
    }

    public static func invalidStyleName(text: String) -> TokenizationError {
        return TokenizationError(message: "Entered value: <\(text)> isn't valid style name.")
    }

    public static func invalidTemplateName(text: String) -> TokenizationError {
        return TokenizationError(message: "Entered value: <\(text)> isn't valid template name.")
    }
}
