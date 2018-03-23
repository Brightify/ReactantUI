//
//  PropertyMaterializationError.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

public enum PropertyMaterializationError: Error {
    case unknownValue(String)

    public var localizedDescription: String {
        switch self {
        case .unknownValue(let message):
            return "Unknown value - \(message)"
        }
    }
}

extension PropertyMaterializationError: LocalizedError {
    public var errorDescription: String? {
        return localizedDescription
    }
}
