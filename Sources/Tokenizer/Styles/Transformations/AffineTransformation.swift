//
//  AffineTransformation.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 23/06/2017.
//
//

import Foundation

public struct AffineTransformation: SupportedPropertyType {
    
    public let transformations: [TransformationModifier]
    
    public var generated: String {
        return transformations.map { $0.generated }.joined(separator: " + ")
    }
    
    public static func materialize(from value: String) throws -> AffineTransformation {
        let tokens = Lexer.tokenize(input: value)
        let modifiers = try TransformationParser(tokens: tokens).parse()
        return AffineTransformation(transformations: modifiers)
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
        return transformations.map { $0.dematerialize() }.joined(separator: " ")
    }
    #endif
    
    #if ReactantRuntime
    public var runtimeValue: Any? {
        var cgTransform = CGAffineTransform.identity
        for transformation in transformations {
            switch transformation {
            case .identity:
                continue
            case .rotate(by: let degrees):
                cgTransform = cgTransform.rotated(by: CGFloat((.pi/180) * degrees))
            case .scale(byX: let x, byY: let y):
                cgTransform = cgTransform.scaledBy(x: CGFloat(x), y: CGFloat(y))
            case .translate(byX: let x, byY: let y):
                cgTransform = cgTransform.translatedBy(x: CGFloat(x), y: CGFloat(y))
            }
        }
        return cgTransform
    }
    #endif
}
