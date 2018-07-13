//
//  Logger.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 13/07/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation

final class Logger {
    static let instance = Logger()

    var errorCode: Int

    // forcing the use of singleton
    private init() {
        errorCode = 0
    }

    func warning(_ message: String, path: String? = nil, line: Int? = 0) {
        let location = getLocation(path: path, line: line)
        print("\(location ?? "")warning: ReactantUI: \(message)")
    }

    func error(_ message: String, path: String? = nil, line: Int? = 0, errorCode: Int = 1) {
        let location = getLocation(path: path, line: line)
        print("\(location ?? "")error: ReactantUI: \(message)")
        self.errorCode = errorCode
    }

    private func getLocation(path: String?, line: Int?) -> String? {
        let location: String?
        if let path = path, let line = line {
            location = path.appending(":\(String(line)): ")
        } else {
            location = nil
        }
        return location
    }
}
