//
//  FormatTokeniser.swift
//  
//
//  Created by Nick on 05/03/2023.
//

import Foundation

// MARK: - Format Tokeniser

struct FormatTokeniser {
    
    private typealias Word = (offset: String.Index, content: String)
    
    struct Token {
        let tokenOffset: String.Index
        let tokenLength: Int
        let prefixNumber: Int?
        let code: String?
        let content: [String]
    }
    
    static func tokenise(formatString: String) -> [Token] {
        let words = splitIntoWords(formatString)
        let chunks = aggregateIntoDescriptorChunks(words)
        let tokens = chunks.map { chunk in makeTokenFromChunk(chunk) }
        
        return tokens
    }
    
}

// MARK: - Token Constructor

extension FormatTokeniser {
    
    private static func makeTokenFromChunk(_ chunk: [Word]) -> Token {
        precondition(!chunk.isEmpty)
        
        guard let firstWord = chunk.first else { fatalError() }
        let offset = firstWord.offset
        let length = chunk.reduce(0) { sum, word in sum + word.content.count }
        
        var remaining = chunk[0...]
        
        var prefixNumber: Int? = nil
        if let parsedNumber = Int(firstWord.content) {
            prefixNumber = parsedNumber
            remaining = remaining.dropFirst()
        }
        
        let code = remaining.first?.content
        remaining = remaining.dropFirst()
        
        return Token(
            tokenOffset: offset,
            tokenLength: length,
            prefixNumber: prefixNumber,
            code: code,
            content: remaining.map { word in word.content })
    }
    
}

// MARK: - String Manipulation

extension FormatTokeniser {
    
    private static func splitIntoWords(_ string: String) -> [Word] {
        var words = [Word]()
        var previous: Character?
        var chars = [Character]()
        var wordOffset = string.startIndex
        var currentOffset = string.startIndex
        
        func addWord() {
            guard !chars.isEmpty else { return }
            let word = (wordOffset, chars.concatenated())
            words.append(word)
            chars = []
            wordOffset = currentOffset
        }
        
        for char in string {
            var isWordStart = char == "," || char == " " || char == "." || char.isSign
            
            if let previous = previous {
                isWordStart = isWordStart
                || char.isLetter && !previous.isLetter
                || char.isNumber && !previous.isNumber && !previous.isSign
            }
                        
            if isWordStart { addWord() }
            
            chars.append(char)
            previous = char
            currentOffset = string.index(after: currentOffset)
        }
        
        addWord()
        return words
    }
    
    private static func aggregateIntoDescriptorChunks(
        _ words: [Word]
    ) -> [[Word]] {
        var chunks = [[Word]]()
        var chunk = [Word]()
        
        func addChunk() {
            chunks.append(chunk)
            chunk = []
        }
        
        for word in words {
            if word.content == "," {
                addChunk()
                continue
            }
            
            if word.content == " " {
                if !chunk.isEmpty { addChunk() }
                continue
            }
            
            chunk.append(word)
        }
        
        if !chunk.isEmpty { addChunk() }
        return chunks
    }
    
}

// MARK: - Character Helper

fileprivate extension Character {
    
    var isSign: Bool { self == "-" || self == "+" }
    
}
