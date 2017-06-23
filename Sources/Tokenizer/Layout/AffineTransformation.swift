//
//  AffineTransformation.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 23/06/2017.
//
//

import Foundation

public struct AffineTransformation: XMLAttributeDeserializable {
    public let transformations: [Transformation]

    public static func deserialize(_ attribute: XMLAttribute) throws -> AffineTransformation {
        return AffineTransformation(transformations: try Transformation.transformations(attribute: attribute))
    }
}
