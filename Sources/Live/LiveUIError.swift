//
//  LiveUIError.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct LiveUIError: Error {
    let message: String

    public init(message: String) {
        self.message = message
    }
}
