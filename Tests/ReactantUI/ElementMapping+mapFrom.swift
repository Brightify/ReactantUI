//
//  ElementMapping+mapFrom.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 14/06/2018.
//

import ReactantLiveUI

extension ElementMapping {
    static func mapFrom(element: XMLElement) throws -> View {
        guard let mapping = ElementMapping.mapping[element.name] else {
            throw TestError.noMappingFound
        }
        return try mapping.deserialize(element)
    }
}
