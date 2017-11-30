//
//  XMLElement+Utils.swift
//  ReactantUI
//
//  Created by Matous Hybl on 18/08/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

extension XMLElement {
    func value<T: XMLElementDeserializable>() throws -> T {
        return try T.deserialize(self)
    }
    
    var indexer: XMLIndexer {
        return XMLIndexer(self)
    }
    
    func elements(named: String) -> [XMLElement] {
        return xmlChildren.filter { $0.name == named }
    }
    
    func singleElement(named: String) throws -> XMLElement {
        let allNamedElements = elements(named: named)
        guard allNamedElements.count == 1 else {
            throw TokenizationError(message: "Requires element named `\(named)` to be defined!")
        }
        return allNamedElements[0]
    }
    
    func singleOrNoElement(named: String) throws -> XMLElement? {
        let allNamedElements = elements(named: named)
        guard allNamedElements.count <= 1 else {
            throw TokenizationError(message: "Maximum number of elements named `\(named)` is 1!")
        }
        return allNamedElements.first
    }
}
