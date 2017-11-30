//
//  StringUtils.swift
//  ReactantUI
//
//  Created by Matyas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

extension String {
    public func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }

}
