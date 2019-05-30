//
//  XMLElementSerializable.swift
//  Hyperdrive-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

public protocol XMLElementSerializable {
    // FIXME This should not be used for serialization of Components because it brings DataContext to XSD
    func serialize(context: DataContext) -> XMLSerializableElement
}
