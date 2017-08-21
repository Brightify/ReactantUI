//
//  ConstraintParser.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/29/17.
//
//

enum ParseError: Error {
    case unexpectedToken(Lexer.Token)
    case message(String)
}

class BaseParser<ITEM> {
    private var tokens: [Lexer.Token]
    private var position: Int = 0
    
    init(tokens: [Lexer.Token]) {
        self.tokens = tokens
    }
    
    func parse() throws -> [ITEM] {
        // Reset
        let tokensBackup = tokens
        defer {
            tokens = tokensBackup
            position = 0
        }
        
        var items = [] as [ITEM]
        while !hasEnded() {
            let currentPosition = position
            
            let item = try parseSingle()
            items.append(item)
            
            if let token = peekToken(), currentPosition == position {
                throw ParseError.unexpectedToken(token)
            }
        }
        return items
    }
    
    func hasEnded() -> Bool {
        return peekToken() == nil
    }
    
    func parseSingle() throws -> ITEM {
        fatalError("Abstract!")
    }
    
    func peekToken() -> Lexer.Token? {
        guard position < tokens.count else { return nil }
        return tokens[position]
    }
    
    func peekNextToken() -> Lexer.Token? {
        guard position < tokens.count - 1 else { return nil }
        return tokens[position + 1]
    }
    
    func peekNext<T>(_ f: (Lexer.Token) throws -> T?) rethrows -> T? {
        guard let nextToken = peekNextToken() else { return nil }
        position += 1
        defer { position -= 1 }
        return try f(nextToken)
    }
    
    @discardableResult
    func popTokens(_ count: Int) throws -> [Lexer.Token] {
        guard position < tokens.count - count + 1 else {
            throw ParseError.message("Cannot advance token. Current: \(String(describing: peekToken())).")
        }
        let poppedTokens = tokens[position..<position+count]
        position += count
        return Array(poppedTokens)
    }
    
    @discardableResult
    func popToken() throws -> Lexer.Token {
        guard position < tokens.count else {
            throw ParseError.message("Cannot advance token. Current: \(String(describing: peekToken())).")
        }
        let token = tokens[position]
        position += 1
        return token
    }
    
    @discardableResult
    func popLastToken() throws -> Lexer.Token {
        guard !tokens.isEmpty else {
            throw ParseError.message("Cannot pop last token")
        }
        return tokens.removeLast()
    }
}

class ConstraintParser: BaseParser<Constraint> {
    private let layoutAttribute: LayoutAttribute
    
    init(tokens: [Lexer.Token], layoutAttribute: LayoutAttribute) {
        self.layoutAttribute = layoutAttribute
        super.init(tokens: tokens)
    }
    
    override func parseSingle() throws -> Constraint {
        let field = try parseField()
        
        let relation = try parseRelation() ?? .equal
        
        let type: ConstraintType
        if case .number(let constant)? = peekToken() {
            type = .constant(constant)
            try popToken()
        } else {
            let target = try parseTarget()
            let targetAnchor = try parseTargetAnchor()
            
            var multiplier = 1 as Float
            var constant = 0 as Float
            while try !constraintEnd(), let modifier = try parseModifier() {
                switch modifier {
                case .multiplied(let by):
                    multiplier *= by
                case .divided(let by):
                    multiplier /= by
                case .offset(let by):
                    constant += by
                case .inset(let by):
                    constant += by * layoutAttribute.insetDirection
                }
            }
            
            type = .targeted(target: target ?? (targetAnchor != nil ? .this : .parent),
                             targetAnchor: targetAnchor ?? layoutAttribute.targetAnchor,
                             multiplier: multiplier,
                             constant: constant)
        }
        
        let priority: ConstraintPriority
        if peekToken() != .semicolon {
            priority = try parsePriority() ?? .required
        } else {
            priority = .required
            try popToken()
        }
        
        return Constraint(field: field, attribute: layoutAttribute, type: type, relation: relation, priority: priority)
    }
    
    private func constraintEnd() throws -> Bool {
        if hasEnded() {
            return true
        } else if peekToken() == .semicolon {
            return true
        } else {
            return false
        }
    }
    
    private func parseField() throws -> String? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() == .assignment else { return nil }
        
        try popTokens(2)
        return identifier
    }
    
    private func parseRelation() throws -> ConstraintRelation? {
        guard case .colon? = peekToken(), case .identifier(let identifier)? = peekNextToken() else { return nil }
        try popTokens(2)
        
        return try ConstraintRelation(identifier)
    }
    
    private func parseTarget() throws -> ConstraintTarget? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() != .parensOpen else { return nil }
        try popToken()
        if peekToken() == .colon, case .identifier(let layoutId)? = peekNextToken() {
            try popTokens(2)
            return .layoutId(layoutId)
        } else if identifier == "super" {
            return .parent
        } else if identifier == "self" {
            return .this
        } else {
            return .field(identifier)
        }
    }
    
    private func parseTargetAnchor() throws -> LayoutAnchor? {
        guard peekToken() == .period, case .identifier(let identifier)? = peekNextToken() else { return nil }
        try popTokens(2)
        return try LayoutAnchor(identifier)
    }
    
    private func parseModifier() throws -> ConstraintModifier? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() == .parensOpen else { return nil }
        try popTokens(2)
        
        if case .identifier("by")? = peekToken(), peekNextToken() == .colon {
            try popTokens(2)
        }
        
        guard case .number(let number)? = peekToken(), .parensClose == peekNextToken() else {
            throw ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
        }
        try popTokens(2)
        
        switch identifier {
        case "multiplied":
            return .multiplied(by: number)
        case "divided":
            return .divided(by: number)
        case "offset":
            return .offset(by: number)
        case "inset":
            return .inset(by: number)
        default:
            throw ParseError.message("Unknown modifier `\(identifier)`")
        }
    }
    
    private func parsePriority() throws -> ConstraintPriority? {
        guard case .at? = peekToken() else { return nil }
        if case .number(let number)? = peekNextToken() {
            try popTokens(2)
            return ConstraintPriority.custom(number)
        } else if case .identifier(let identifier)? = peekNextToken() {
            try popTokens(2)
            return try ConstraintPriority(identifier)
        } else {
            throw ParseError.message("Missing priority value! `@` token followed by \(peekNextToken().map(String.init(describing:)) ?? "none")")
        }
    }
}

public enum TransformedText {
    case text(String)
    indirect case transform(Transform, TransformedText)
    
    public enum Transform: String {
        case uppercased
        case lowercased
        case localized
        case capitalized
    }
}



class TextParser: BaseParser<TransformedText> {
    override func parseSingle() throws -> TransformedText {
        if peekToken() == .colon {
            let transformIdentifier: String? = peekNext {
                guard case .identifier(let identifier) = $0, peekNextToken() == .parensOpen else { return nil }
                return identifier
            }
            if let identifier = transformIdentifier {
                try popTokens(3)
                let lastToken = try popLastToken()
                guard lastToken == .parensClose else {
                    throw ParseError.message("Unexpected token `\(lastToken)`, expected `)` to be the last token")
                }
                let inner = try parseSingle()
                guard let transform = TransformedText.Transform(rawValue: identifier) else {
                    throw ParseError.message("Unknown text transform :\(identifier)")
                }
                return .transform(transform, inner)
            }
        }
        
        var components = [] as [String]
        while let token = peekToken() {
            try popToken()
            switch token {
            case .identifier(let identifier):
                components.append(identifier)
            case .number(let number):
                components.append("\(number)")
            case .parensOpen:
                components.append("(")
            case .parensClose:
                components.append(")")
            case .assignment:
                components.append("=")
            case .operatorToken(let op):
                components.append(op)
            case .colon:
                components.append(":")
            case .semicolon:
                components.append(";")
            case .period:
                components.append(".")
            case .at:
                components.append("@")
            case .other(let other):
                components.append(other)
            case .whitespace(let whitespace):
                components.append(whitespace)
            }
        }
        return .text(components.joined())
    }
}

class FontParser: BaseParser<Font> {
    override func parseSingle() throws -> Font {
        if case .colon? = peekToken() {
            try popToken()
            let possibleWeightToken = try popToken()
            guard case .identifier(let possibleWeight) = possibleWeightToken else {
                throw ParseError.message("Unexpected token `\(possibleWeightToken)`, expected weight identifier")
            }
            guard let weight = SystemFontWeight(rawValue: possibleWeight) else {
                throw ParseError.message("Unknown weight name `\(possibleWeight)`!")
            }
            let size: Float
            if case .at? = try? popToken() {
                let possibleSize = try popToken()
                guard case .number(let fontSize) = possibleSize else {
                    throw ParseError.message("Unexpected token `\(possibleSize)`, expected font size float")
                }
                size = fontSize
            } else {
                // Default
                size = 15
            }
            return .system(weight: weight, size: size)
        } else if case .number(let size)? = peekToken() {
            try popToken()
            return .system(weight: .regular, size: size)
        } else {
            var components = [] as [String]
            while let token = peekToken() {
                guard token != .at else { break }
                
                try popToken()
                switch token {
                case .identifier(let identifier):
                    components.append(identifier)
                case .number(let number):
                    components.append("\(number)")
                case .parensOpen:
                    components.append("(")
                case .parensClose:
                    components.append(")")
                case .assignment:
                    components.append("=")
                case .operatorToken(let op):
                    components.append(op)
                case .colon:
                    components.append(":")
                case .semicolon:
                    components.append(";")
                case .period:
                    components.append(".")
                case .at:
                    break
                case .other(let other):
                    components.append(other)
                case .whitespace(let whitespace):
                    components.append(whitespace)
                }
            }
            let size: Float
            if case .at? = try? popToken() {
                let possibleSize = try popToken()
                guard case .number(let fontSize) = possibleSize else {
                    throw ParseError.message("Unexpected token `\(possibleSize)`, expected font size float")
                }
                size = fontSize
            } else {
                // Default
                size = 15
            }
            return .named(components.joined(), size: size)
        }
    }
}


