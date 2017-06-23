//
//  Transformation.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 23/06/2017.
//
//

import Foundation

public struct Transformation: XMLAttributeDeserializable {
    public let modifier: TransformationModifier

    public static func transformations(attribute: XMLAttribute) throws -> [Transformation] {
        let tokens = Lexer.tokenize(input: attribute.text)
        return try TransformationParser(tokens: tokens).parse()
    }
}
