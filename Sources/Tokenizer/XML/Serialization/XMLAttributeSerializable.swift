//
//  XMLAttributeSerializable.swift
//  Hyperdrive-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

public protocol XMLAttributeSerializable {
    func serialize() -> XMLSerializableAttribute
}
