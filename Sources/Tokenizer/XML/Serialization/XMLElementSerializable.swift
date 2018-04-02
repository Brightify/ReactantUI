//
//  XMLElementSerializable.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

public protocol XMLElementSerializable {
    func serialize() -> XMLSerializableElement
}
