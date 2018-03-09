//
//  Collection+groupBy.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

extension Collection {

    public func groupBy<KEY: Hashable>(_ extractKey: (Iterator.Element) -> KEY) -> [(KEY, [Iterator.Element])] {
        return groupBy { Optional(extractKey($0)) }
    }

    public func groupBy<KEY: Hashable>(_ extractKey: (Iterator.Element) -> KEY?) -> [(KEY, [Iterator.Element])] {
        var grouped: [(KEY, [Iterator.Element])] = []
        var t: [String] = []
        func add(_ item: Iterator.Element, forKey key: KEY) {
            if let index = grouped.index(where: { $0.0 == key }) {
                var value = grouped[index]
                value.1.append(item)
                grouped[index] = (key, value.1)
            } else {
                grouped.append((key, [item]))
            }
        }

        for item in self {
            guard let key = extractKey(item) else {
                continue
            }
            add(item, forKey: key)
        }
        return grouped
    }
}
