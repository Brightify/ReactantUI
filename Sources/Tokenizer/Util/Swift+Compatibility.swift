//
//  Swift+Compatibility.swift
//  Differentiator-iOS
//
//  Created by Matouš Hýbl on 06/04/2018.
//

import Foundation

#if !swift(>=4.1)
public extension Sequence {
    public func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try self.flatMap(transform)
    }
}
#endif
