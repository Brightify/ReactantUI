//
//  StringUtils.swift
//  ReactantUI
//
//  Created by Matyas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

extension String {
    public func capitalizingFirstLetter() -> String {
        let first = String(self[self.startIndex]).capitalized
        let other = String(self.dropFirst())
        return first + other
    }
}
