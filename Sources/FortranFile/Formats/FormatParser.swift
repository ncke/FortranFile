//
//  FormatParser.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import Foundation

// MARK: - Format Parser

struct FormatParser {
    
    private typealias Expression = [Token]
    
    static func parse(string: String) throws -> FortranFile.Format {
        let tokens = try tokenise(formatString: string)
        let expressions = groupIntoExpressions(tokens: tokens)
        let format = try generate(from: expressions, input: string)
        
        return format
    }
    
}

// MARK: - Token

extension FormatParser {
    
    struct Token {
        enum TokenType {
            case comma
            case space
            case point
            case digits(n: Int)
            case text(t: String)
        }
        
        let tokenType: TokenType
        let offset: Int
        let length: Int
        
        var digits: Int? {
            guard case TokenType.digits(let n) = tokenType else {
                return nil
            }
            
            return n
        }
        
        var text: String? {
            guard case TokenType.text(let t) = tokenType else {
                return nil
            }
            
            return t
        }
    }
    
}

// MARK: - Tokeniser

extension FormatParser {
    
    private static func tokenise(formatString: String) throws -> [Token] {
        var tokens = [Token]()
        var lexeme = String()
        var isInsideDigits = false
        var offset: Int = 0
        
        func commitToken(_ token: Token? = nil, nextOffset: Int?) {
            let commit: Token
            
            if let token = token {
                commit = token
            } else if isInsideDigits, let number = Int(lexeme) {
                commit = Token(
                    tokenType: .digits(n: number),
                    offset: offset,
                    length: lexeme.count)
            } else if !lexeme.isEmpty {
                commit = Token(
                    tokenType: .text(t: lexeme),
                    offset: offset,
                    length: lexeme.count)
            } else {
                return
            }
            
            tokens.append(commit)
            
            lexeme = String()
            if let nextOffset = nextOffset {
                offset = nextOffset
            }
        }
        
        for i in 0..<formatString.count {
            let input = try formatString.excerpt(i, 1)
            let isDigit = input >= "0" && input <= "9"
            
            if !isDigit && isInsideDigits {
                commitToken(nextOffset: i)
                isInsideDigits = false
            }
            
            if isDigit && !isInsideDigits {
                commitToken(nextOffset: i)
                isInsideDigits = true
            }
            
            if let characterTokenType = characterTokenTypes[input] {
                commitToken(nextOffset: i)
                let characterToken = Token(
                    tokenType: characterTokenType,
                    offset: offset,
                    length: 1)
                commitToken(characterToken, nextOffset: i + 1)
                continue
            }

            lexeme += input
        }
        
        commitToken(nextOffset: nil)
        
        return tokens
    }
    
    private static let characterTokenTypes: [Substring: Token.TokenType] = [
        ",": .comma,
        " ": .space,
        ".": .point
    ]
    
}

// MARK: - Expression Grouping

extension FormatParser {
    
    private static func groupIntoExpressions(tokens: [Token]) -> [Expression] {
        var expressions = [Expression]()
        var expression = Expression()
        
        func commit() {
            guard !expression.isEmpty else { return }
            expressions.append(expression)
            expression = []
        }
        
        for token in tokens {
            if token.isSeparator {
                commit()
                
                if token.shouldConsumeAsSeparator {
                    continue
                }
            }
            
            expression.append(token)
        }
        
        commit()
        
        return expressions
    }
    
}

// MARK: - Format Generator

extension FormatParser {
    
    private static func generate(
        from expressions: [Expression],
        input: String
    ) throws -> FortranFile.Format {
        
        var items = [FortranFile.Format.Item]()
        
        for tokens in expressions {
            var remaining = tokens
        
            var repeatFactor: Int? = nil
            if let repeats = remaining.first,
               let n = repeats.digits
            {
                repeatFactor = n
                remaining = Array(remaining.dropFirst())
            }
            
            guard
                let descriptorToken = remaining.first,
                let descriptor = descriptorToken.asTextDescriptor
            else {
                throw FortranFile.FormatError(
                    kind: .missingDescriptor,
                    input: input,
                    tokens: tokens)
            }
            
            remaining = Array(remaining.dropFirst())
            
            let (width, decimals) = try parseSizes(
                tokens: remaining,
                input: input)
            
            let item = FortranFile.Format.Item(
                descriptor: descriptor,
                repeatFactor: repeatFactor,
                width: width,
                decimals: decimals)
            
            try validateItemSemantics(item: item, tokens: tokens, input: input)
            
            items.append(item)
        }
        
        let format = FortranFile.Format(items: items)
        return format
    }

    private static func parseSizes(
        tokens: [Token],
        input: String
    ) throws -> (Int?, Int?) {
        
        guard tokens.count <= 3 else {
            throw FortranFile.FormatError(
                kind: .unexpectedSymbols,
                input: input,
                tokens: tokens)
        }
        
        switch (tokens.count > 0 ? tokens[0].digits : nil,
                tokens.count > 1 ? tokens[1].tokenType : nil,
                tokens.count > 2 ? tokens[2].digits : nil)
        {
        case (.none, .none, .none):
            return (nil, nil)
            
        case (.some(let w), .some(.point), .some(let d)):
            return (w, d)
        
        case (.some(let w), .none, .none):
            return (w, nil)
            
        default:
            throw FortranFile.FormatError(
                kind: .unexpectedSymbols,
                input: input,
                tokens: tokens)
        }
    }

}

// MARK: - Semantic Validation

extension FormatParser {
    
    private static func validateItemSemantics(
        item: FortranFile.Format.Item,
        tokens: [Token],
        input: String
    ) throws {
        
        if item.descriptor.requiresWidth && item.width == nil {
            throw FortranFile.FormatError(
                kind: .missingFieldWidth,
                input: input,
                tokens: tokens)
        }
        
        if item.descriptor.requiresDecimals && item.decimals == nil {
            throw FortranFile.FormatError(
                kind: .missingFieldDecimals,
                input: input,
                tokens: tokens)
        }
        
        if item.descriptor.requiresNonDimensioned
                && (item.width != nil || item.decimals != nil)
        {
            throw FortranFile.FormatError(
                kind: .unexpectedDimensions,
                input: input,
                tokens: tokens)
        }
        
        if item.descriptor.requiresNoRepeatFactor
            && item.repeatFactor != nil
        {
            throw FortranFile.FormatError(
                kind: .descriptorIsNonRepeatable,
                input: input,
                tokens: tokens)
        }
    }
    
}

// MARK: - Format Error Helpers

fileprivate extension FortranFile.FormatError {
    
    init(kind: ErrorKind, input: String, tokens: [FormatParser.Token]) {
        self.kind = kind
        self.input = input
        self.offset = tokens.first?.offset ?? 0
        self.length = tokens.reduce(0) { accum, token in accum + token.length }
    }

}

// MARK: - Token Helpers

fileprivate extension FormatParser.Token {
    
    var isSeparator: Bool {
        switch self.tokenType {
        case .text, .digits, .point: return false
        default: return true
        }
    }
    
    var shouldConsumeAsSeparator: Bool {
        switch self.tokenType {
        case .comma, .space: return true
        default: return false
        }
    }
    
    var asTextDescriptor: FortranFile.Format.Descriptor? {
        guard let t = self.text else { return nil }
        return Self.descriptorMap[t.uppercased()]
    }
    
    static let descriptorMap: [String: FortranFile.Format.Descriptor] = [
        "A":    .aTextString,
        "D":    .dDoublePrecision,
        "E":    .eRealExponent,
        "F":    .fRealFixedPoint,
        "I":    .iInteger,
        "X":    .xHorizontalSkip,
        "P":    .pScaleFactor,
        "B":    .bBlanksDefault,
        "BN":   .bnBlanksIgnore,
        "BZ":   .bzBlanksZero
    ]
    
}

// MARK: - Descriptor Helpers

fileprivate extension FortranFile.Format.Descriptor {
    
    var requiresWidth: Bool {
        switch self {
        case .xHorizontalSkip, .pScaleFactor: return false
        default: return true
        }
    }
    
    var requiresDecimals: Bool {
        switch self {
        case .dDoublePrecision,
             .eRealExponent,
             .fRealFixedPoint,
             .gRealDecimal: return true
        default: return false
        }
    }
    
    var requiresNonDimensioned: Bool {
        switch self {
        case .xHorizontalSkip,
             .pScaleFactor,
             .bBlanksDefault,
             .bnBlanksIgnore,
             .bzBlanksZero: return true
        default: return false
        }
    }
    
    var requiresNoRepeatFactor: Bool {
        switch self {
        case .pScaleFactor,
             .bBlanksDefault,
             .bnBlanksIgnore,
             .bzBlanksZero: return true
        default: return false
        }
    }
    
}
