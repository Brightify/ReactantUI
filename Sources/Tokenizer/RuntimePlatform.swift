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
}
