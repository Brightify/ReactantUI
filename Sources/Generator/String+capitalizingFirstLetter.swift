//
//  String+capitalizingFirstLetter.swift
//  ReactantUIGenerator
//
//  Created by Matouš Hýbl on 07/03/2018.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(self[self.startIndex]).capitalized
        let other = String(self.dropFirst())
        return first + other
    }
}
