//
//  Array+subarrays.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 12/06/2018.
//

import Foundation

extension Array {
    public init(subarrays: [[Iterator.Element]]) {
        self.init(subarrays.flatMap { $0 })
    }

    public init(subarrays: [Iterator.Element]...) {
        self.init(subarrays: subarrays)
    }
}
