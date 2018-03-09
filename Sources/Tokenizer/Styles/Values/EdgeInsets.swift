//
//  EdgeInsets.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct EdgeInsets: SupportedPropertyType {
    public let top: Float
    public let left: Float
    public let bottom: Float
    public let right: Float

    public init(top: Float = 0, left: Float = 0, bottom: Float = 0, right: Float = 0) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }

    public init(top: Double = 0, left: Double = 0, bottom: Double = 0, right: Double = 0) {
        self.init(top: Float(top), left: Float(left), bottom: Float(bottom), right: Float(right))
    }

    public init(horizontal: Float, vertical: Float) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    public var generated: String {
        return "UIEdgeInsetsMake(\(top.cgFloat), \(left.cgFloat), \(bottom.cgFloat), \(right.cgFloat))"
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
        return "top: \(top), left: \(left), bottom: \(bottom), right: \(right)"
    }
    #endif

    public static func materialize(from value: String) throws -> EdgeInsets {
        let tokens = Lexer.tokenize(input: value)
        let dimensions = try DimensionParser(tokens: tokens).parse()
        if let allDimension = dimensions.first, dimensions.count == 1, allDimension.identifier == "all" || allDimension.identifier == nil {
            return EdgeInsets(horizontal: allDimension.value, vertical: allDimension.value)
        } else if dimensions.count == 2 {
            let horizontal = (dimensions.first(where: { $0.identifier == "horizontal" }) ?? dimensions[0]).value
            let vertical = (dimensions.first(where: { $0.identifier == "vertical" }) ?? dimensions[1]).value

            return EdgeInsets(horizontal: horizontal, vertical: vertical)
        } else if dimensions.count == 4 && (dimensions.filter { $0.identifier == nil }).count == 4 { // all are without labels
            let top = dimensions[0].value
            let left = dimensions[1].value
            let bottom = dimensions[2].value
            let right = dimensions[3].value

            return EdgeInsets(top: top, left: left, bottom: bottom, right: right)
        } else if dimensions.count == 4 && (dimensions.filter { $0.identifier != nil }).count == 4 { // all have labels
            guard let top = dimensions.first(where: { $0.identifier == "top" })?.value,
                let left = dimensions.first(where: { $0.identifier == "left" })?.value,
                let bottom = dimensions.first(where: { $0.identifier == "bottom" })?.value,
                let right = dimensions.first(where: { $0.identifier == "right" })?.value else {
                    throw PropertyMaterializationError.unknownValue(value)
                }

            return EdgeInsets(top: top, left: left, bottom: bottom, right: right)
        } else {
            if let horizontal = dimensions.first(where: { $0.identifier == "horizontal" })?.value {
                let top = dimensions.first(where: { $0.identifier == "top" })?.value ?? 0
                let bottom = dimensions.first(where: { $0.identifier == "bottom" })?.value ?? 0

                return EdgeInsets(top: top, left: horizontal, bottom: bottom, right: horizontal)
            } else if let vertical = dimensions.first(where: { $0.identifier == "vertical" })?.value {
                let left = dimensions.first(where: { $0.identifier == "left" })?.value ?? 0
                let right = dimensions.first(where: { $0.identifier == "right" })?.value ?? 0

                return EdgeInsets(top: vertical, left: left, bottom: vertical, right: right)
            } else {
                let top = dimensions.first(where: { $0.identifier == "top" })?.value ?? 0
                let bottom = dimensions.first(where: { $0.identifier == "bottom" })?.value ?? 0
                let left = dimensions.first(where: { $0.identifier == "left" })?.value ?? 0
                let right = dimensions.first(where: { $0.identifier == "right" })?.value ?? 0

                return EdgeInsets(top: top, left: left, bottom: bottom, right: right)
            }
        }
    }
}

#if ReactantRuntime
import UIKit

extension EdgeInsets {

    public var runtimeValue: Any? {
        return UIEdgeInsetsMake(top.cgFloat, left.cgFloat, bottom.cgFloat, right.cgFloat)
    }
}
#endif
