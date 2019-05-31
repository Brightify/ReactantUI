//
//  ActionParser.swift
//  Tokenizer
//
//  Created by Matyáš Kříž on 31/05/2019.
//

import Foundation

// EBNF as of making this parser:
// ACTION := IDENTIFIER [ '(' PARAMETER [ ',' PARAMETER ] ')' ]
// PARAMETER := ( INHERITED | STATE_VARIABLE | REFERENCE | CONSTANT )
// INHERITED := '...'
// STATE_VARIABLE := '$' IDENTIFIER [ '.' IDENTIFIER ]*
// REFERENCE := '@' IDENTIFIER [ '.' IDENTIFIER ]*
// CONSTANT := { anything valid in source language }
// IDENTIFIER := { as is defined in Lexer.Token.identifier }
class ActionParser: BaseParser<HyperViewAction> {
    override func parseSingle() throws -> HyperViewAction {
        return try parseAction(eventName: "CALL PARSER `ActionParser` BY `parseAction(eventName:)`!")
    }

    func parseAction(eventName: String) throws -> HyperViewAction {
        guard case .identifier(let name) = try popToken() else { throw ParseError.expectedToken(.identifier("anyIdentifier")) }
        let parameters: [(label: String?, parameter: HyperViewAction.Parameter)]
        if try matchToken(.parensOpen) {
            var parsedParameters = [] as [(label: String?, parameter: HyperViewAction.Parameter)]
            repeat {
                parsedParameters.append(try parseLabeledParameter())
            } while try matchToken(.comma)
            guard try matchToken(.parensClose) else { throw ParseError.expectedToken(.parensClose) }
            parameters = parsedParameters
        } else {
            parameters = []
        }

        return HyperViewAction(name: name, eventName: eventName, parameters: parameters)
    }

    private func parseLabeledParameter() throws -> (label: String?, parameter: HyperViewAction.Parameter) {
        let label: String?
        if case .identifier(let possibleLabel)? = peekToken(), case .colon? = peekNextToken() {
            label = possibleLabel
            try popTokens(2)
        } else {
            label = nil
        }

        return (label, try parseParameter())
    }

    private func parseParameter() throws -> HyperViewAction.Parameter {
        let firstToken = try popToken()
        switch firstToken {
        case .period:
            guard try matchToken(.period), try matchToken(.period) else { throw ParseError.expectedToken(.period) }
            return HyperViewAction.Parameter.inheritedParameters
        case .at:
            guard case .identifier(let targetId) = try popToken() else { throw ParseError.expectedToken(.identifier("Action reference target name.")) }
            var property = ""
            if try matchToken(.period) {
                theWheel:
                while let token = peekToken() {
                    switch token {
                    case .identifier(let identifier):
                        property.append(identifier)
                        try popToken()
                    case .period:
                        property.append(".")
                        try popToken()
                    default:
                        break theWheel
                    }
                }
            }
            return HyperViewAction.Parameter.reference(targetId: targetId, property: property.isEmpty ? nil : property)
        case .dollar:
            guard case .identifier(let name) = try popToken() else { throw ParseError.expectedToken(.identifier("State variable name.")) }
            var fullName = name
            theWheel:
                while let token = peekToken() {
                    switch token {
                    case .identifier(let identifier):
                        fullName.append(identifier)
                        try popToken()
                    case .period:
                        fullName.append(".")
                        try popToken()
                    default:
                        break theWheel
                    }
            }
            return HyperViewAction.Parameter.stateVariable(name: fullName)
        case .identifier(let identifier):
            guard try matchToken(.parensOpen) else { throw ParseError.expectedToken(.parensOpen) }
            let parameter: String
            let token = peekToken()
            switch token {
            case .parensClose?:
                parameter = ""
            case .identifier(let string)?:
                parameter = string
                try popToken()
            case .number(_, let original)?:
                parameter = original
                try popToken()
            default:
                throw ParseError.message("Unsupported constant value token \(String(describing: token)).")
            }
            guard try matchToken(.parensClose) else { throw ParseError.expectedToken(.parensClose) }
            return HyperViewAction.Parameter.constant(type: identifier, value: parameter)
        default:
            throw ParseError.unexpectedToken(firstToken)
        }
    }
}
