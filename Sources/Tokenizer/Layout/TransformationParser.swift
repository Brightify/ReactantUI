//
//  TransformationParser.swift
//  Pods
//
//  Created by Matyáš Kříž on 23/06/2017.
//
//

class TransformationParser: BaseParser<Transformation> {

    override func parseSingle() throws -> Transformation {
        let modifier = try parseModifier()

        return Transformation(modifier: modifier ?? .identity)
    }

    private func parseModifier() throws -> TransformationModifier? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() == .parensOpen else { return nil }
        try popTokens(2)

        switch identifier {
        case "rotate":
            if case .identifier("by")? = peekToken(), peekNextToken() == .colon {
                try popTokens(2)
            }

            guard case .number(let number)? = peekToken(), .parensClose == peekNextToken() else {
                throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
            }
            try popTokens(2)

            return .rotate(by: Double(number))
        case "scale", "translate":
            var x: Double? = nil
            var y: Double? = nil

            if case .identifier("y")? = peekToken(), peekNextToken() == .colon {
                try popTokens(2)
                guard case .number(let firstCoordinate)? = peekToken() else {
                    throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
                }
                try popToken()
                y = firstCoordinate

                if .comma == peekToken() {
                    try popToken()
                    if case .identifier("x")? = peekToken(), peekNextToken() == .colon {
                        try popTokens(2)
                    }
                    guard case .number(let secondCoordinate)? = peekToken(), .parensClose == peekNextToken() else {
                        throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
                    }
                    try popTokens(2)
                    x = secondCoordinate
                } else {
                    guard .parensClose == peekToken() else {
                        throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
                    }
                }
            } else {
                if case .identifier("x")? = peekToken(), peekNextToken() == .colon {
                    try popTokens(2)
                }
                guard case .number(let firstCoordinate)? = peekToken(),
                    .parensClose == peekNextToken() || .comma == peekNextToken() else {
                    throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
                }
                try popToken()
                x = firstCoordinate

                if .comma == peekToken() {
                    try popToken()
                    if case .identifier("y")? = peekToken(), peekNextToken() == .colon {
                        try popTokens(2)
                    }

                    guard case .number(let secondCoordinate)? = peekToken(), .parensClose == peekNextToken() else {
                        throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
                    }
                    try popTokens(2)
                    y = secondCoordinate
                } else {
                    guard .parensClose == peekToken() else {
                        throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
                    }
                }
            }

            switch identifier {
            case "scale":
                return .scale(byX: x ?? 1, byY: y ?? 1)
            case "translate":
                return .translate(byX: x ?? 0, byY: y ?? 0)
            default:
                return nil //impossible to get here
            }

        default:
            throw ParseError.message("Unknown modifier `\(identifier)`")
        }
    }
}
