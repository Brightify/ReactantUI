//
//  Array+distinctLast.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 13/08/2018.
//

import Foundation

extension Array {
    func distinctLast(comparator: (Element, Element) -> Bool) -> [Element] {
        var newArray: [Element] = []
        for element in self.reversed() where !newArray.contains(where: { comparator(element, $0) }) {
            newArray.insert(element, at: 0)
        }
        return newArray
    }
}

extension Array where Element: Equatable {
    func distinctLast() -> [Element] {
        return distinctLast(comparator: { $0 == $1 })
    }
}
