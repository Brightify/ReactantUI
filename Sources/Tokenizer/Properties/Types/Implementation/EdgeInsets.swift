//
//  EdgeInsets.swift
//  Reactant
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct EdgeInsets: AttributeSupportedPropertyType {
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

    public func generate(context: SupportedPropertyTypeContext) -> String {
        return "UIEdgeInsets(top: \(top.cgFloat), left: \(left.cgFloat), bottom: \(bottom.cgFloat), right: \(right.cgFloat))"
    }
    
    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        return "top: \(top), left: \(left), bottom: \(bottom), right: \(right)"
    }
    #endif

    public static func materialize(from value: String) throws -> EdgeInsets {
        let tokens = Lexer.tokenize(input: value)
        let dimensions = try DimensionParser(tokens: tokens).parse()

        struct OptionalDimensions {
            var top: Float?
            var left: Float?
            var bottom: Float?
            var right: Float?

            init(top: Float? = nil, left: Float? = nil, bottom: Float? = nil, right: Float? = nil) {
                self.top = top
                self.left = left
                self.bottom = bottom
                self.right = right
            }

            func toEdgeInsets() -> EdgeInsets {
                return EdgeInsets(
                    top: top ?? 0,
                    left: left ?? 0,
                    bottom: bottom ?? 0,
                    right: right ?? 0)
            }

            mutating func setDimensions(top: Float? = nil, left: Float? = nil, bottom: Float? = nil, right: Float? = nil) throws {
                if let top = top {
                    if self.top != nil {
                        throw TokenizationError(message: "Duplicate \"top\" dimension in Edge Insets.")
                    }
                    self.top = top
                }
                if let left = left {
                    if self.left != nil {
                        throw TokenizationError(message: "Duplicate \"left\" dimension in Edge Insets.")
                    }
                    self.left = left
                }
                if let bottom = bottom {
                    if self.bottom != nil {
                        throw TokenizationError(message: "Duplicate \"bottom\" dimension in Edge Insets.")
                    }
                    self.bottom = bottom
                }
                if let right = right {
                    if self.right != nil {
                        throw TokenizationError(message: "Duplicate \"right\" dimension in Edge Insets.")
                    }
                    self.right = right
                }
            }
        }

        let finalDimensions = try dimensions.enumerated().reduce(OptionalDimensions()) { currentDimensions, dimensionData -> OptionalDimensions in
            var mutableCurrentDimensions = currentDimensions
            let (index, dimension) = dimensionData

            switch dimension.identifier {
            case "all"?:
                try mutableCurrentDimensions.setDimensions(top: dimension.value, left: dimension.value, bottom: dimension.value, right: dimension.value)
            case "horizontal"?:
                try mutableCurrentDimensions.setDimensions(left: dimension.value, right: dimension.value)
            case "vertical"?:
                try mutableCurrentDimensions.setDimensions(top: dimension.value, bottom: dimension.value)
            case "top"?:
                try mutableCurrentDimensions.setDimensions(top: dimension.value)
            case "left"?:
                try mutableCurrentDimensions.setDimensions(left: dimension.value)
            case "bottom"?:
                try mutableCurrentDimensions.setDimensions(bottom: dimension.value)
            case "right"?:
                try mutableCurrentDimensions.setDimensions(right: dimension.value)
            default:
                if let dimensionIdentifier = dimension.identifier {
                    throw ParseError.message("Edge Insets identifier \(dimensionIdentifier) is invalid. Choose from: ['all', 'horizontal', 'vertical', 'top', 'left', 'bottom', 'right'].")
                }

                if dimensions.count == 1 {
                    // all sides
                    try mutableCurrentDimensions.setDimensions(top: dimension.value, left: dimension.value, bottom: dimension.value, right: dimension.value)
                } else if dimensions.count == 2 {
                    switch index {
                    case 0:
                        // horizontal
                        try mutableCurrentDimensions.setDimensions(left: dimension.value, right: dimension.value)
                    case 1:
                        // vertical
                        try mutableCurrentDimensions.setDimensions(top: dimension.value, bottom: dimension.value)
                    default:
                        fatalError("The IF condition should prevent this from happening.")
                    }
                } else if dimensions.count == 4 {
                    switch index {
                    case 0:
                        // top
                        try mutableCurrentDimensions.setDimensions(top: dimension.value)
                    case 1:
                        // left
                        try mutableCurrentDimensions.setDimensions(left: dimension.value)
                    case 2:
                        // bottom
                        try mutableCurrentDimensions.setDimensions(bottom: dimension.value)
                    case 3:
                        // right
                        try mutableCurrentDimensions.setDimensions(right: dimension.value)
                    default:
                        fatalError("The IF condition should prevent this from happening.")
                    }
                } else {
                    throw ParseError.message("Invalid unnamed dimension count for Edge Insets. Either use 1 (all), 2 (horizontal, vertical), or 4 (top, left, bottom, right).")
                }
            }

            return mutableCurrentDimensions
        }

        return finalDimensions.toEdgeInsets()
    }

    public static var runtimeType: String = "UIEdgeInsets"

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}

#if canImport(UIKit)
import UIKit

extension EdgeInsets {

    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return UIEdgeInsets(top: top.cgFloat, left: left.cgFloat, bottom: bottom.cgFloat, right: right.cgFloat)
    }
}
#endif
