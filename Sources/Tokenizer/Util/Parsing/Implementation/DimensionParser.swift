//
//  DimensionParser.swift
//  Differentiator-iOS
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

class DimensionParser: BaseParser<(identifier: String?, value: Double)> {
    override func parseSingle() throws -> (identifier: String?, value: Double) {
        let dimension: (identifier: String?, value: Double)
        if case .identifier(let identifier)? = peekToken(), peekNextToken() == .colon {
            try popTokens(2)
            if case .number(let value)? = peekToken() {
                dimension = (identifier: identifier, value: value.value)
                try popToken()
            } else {
                throw ParseError.message("Incorrect format")
            }
        } else if case .number(let value)? = peekToken() {
            try popToken()
            dimension = (identifier: nil, value: value.value)
        } else {
            throw ParseError.message("Incorrect format")
        }

        if peekToken() == .comma {
            try popToken()
        }

        return dimension
    }
}
