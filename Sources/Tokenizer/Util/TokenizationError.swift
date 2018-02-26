//
//  TokenizationError.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct TokenizationError: Error, LocalizedError {
    let message: String

    public var localizedDescription: String {
        return message
    }

    public var errorDescription: String? {
        return message
    }
}
