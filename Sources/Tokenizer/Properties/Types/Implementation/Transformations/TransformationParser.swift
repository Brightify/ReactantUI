//
//  TransformationParser.swift
//  Pods
//
//  Created by Matyáš Kříž on 23/06/2017.
//
//

class TransformationParser: BaseParser<TransformationModifier> {

    override func parseSingle() throws -> TransformationModifier {
        let modifier = try parseModifier()

        return modifier ?? .identity
    }

    private func parseModifier() throws -> TransformationModifier? {
        if peekToken() == .identifier("identity") {
            try popToken()
            return .identity
        }
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() == .parensOpen else { return nil }
        try popTokens(2)

        switch identifier {
        case "rotate":
            if case .identifier("by")? = peekToken(), peekNextToken() == .colon {
                try popTokens(2)
            }

            guard case .number(let number, _)? = peekToken(), .parensClose == peekNextToken() else {
                throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
            }
            try popTokens(2)

            return .rotate(by: number)
        case "scale", "translate":
            var x: Double? = nil
            var y: Double? = nil
            
            if peekToken() == .identifier("x") && peekNextToken() == .colon { //x:, x:y:
                try popTokens(2)
                guard case .number(let parsedX, _)? = peekToken() else {
                    throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
                }
                try popToken()
                x = parsedX
                
                if peekToken() == .comma {
                    try popToken()
                    if peekToken() == .identifier("y") && peekNextToken() == .colon {
                        try popTokens(2)
                        
                        guard case .number(let parsedY, _)? = peekToken() else {
                            throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
                        }
                        y = parsedY
                        try popToken()
                    }
                }
                guard peekToken() == .parensClose else {
                    throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
                }
                try popToken()
            } else if peekToken() == .identifier("y") && peekNextToken() == .colon { //y:
                try popTokens(2)
                
                guard case .number(let parsedY, _)? = peekToken(), peekNextToken() == .parensClose else {
                    throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
                }
                y = parsedY
                try popTokens(2)
            } else if case .number(let parsedX, _)? = peekToken(), peekNextToken() == .comma { //x,y
                try popTokens(2)
                guard case .number(let parsedY, _)? = peekToken(), peekNextToken() == .parensClose else {
                    throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
                }
                x = parsedX
                y = parsedY
                try popTokens(2)
            } else if case .number(let number, _)? = peekToken(), peekNextToken() == .parensClose { //two axis, one number
                x = number
                y = number
                try popTokens(2)
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
