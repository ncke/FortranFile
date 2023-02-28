//
//  FormatParser.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import Foundation

// MARK: - Format Parser

struct FormatParser {
    
    private static let descriptors: [String: any Descriptor.Type] = [
        "A": ATextDescriptor.self,
        "F": FRealDescriptor.self,
        "I": IIntegerDescriptor.self
    ]
    
    private static let commands: [String: any Command.Type] = [
        "X": XSkipCommand.self
    ]
    
}

// MARK: - Parsing

extension FormatParser {
    
    typealias FormatUnit = (offset: String.Index, content: [String])
    
    private typealias Word = (offset: String.Index, content: String)
    
    static func parse(formatString: String) throws -> FortranFile.Format {
        var items = [FortranFile.Format.FormatItem]()
        let words = splitIntoWords(formatString)
        let units = aggregateIntoUnits(words)
        
        for unit in units {
            var remaining = unit.content
            
            func error(
                _ kind: FortranFile.FormatError.ErrorKind
            ) -> FortranFile.FormatError {
                let length = unit.content.reduce(0) { partial, str in
                    partial + str.count
                }
                
                return FortranFile.FormatError(
                    kind: kind,
                    input: formatString,
                    offset: unit.offset,
                    length: max(length, 1))
            }
            
            guard let word = remaining.first else {
                throw error(.expectedDescriptor)
            }
            
            let repeatCount: Int
            if let parsedCount = Int(word) {
                repeatCount = parsedCount
                remaining = Array(remaining.dropFirst())
            } else {
                repeatCount = 1
            }
            
            guard let code = remaining.first?.uppercased() else {
                throw error(.expectedDescriptor)
            }
            
            remaining = Array(remaining.dropFirst())
            
            if let descriptorType = descriptors[code] {
                guard let descriptor = descriptorType.init(
                    formatWords: remaining)
                else {
                    throw error(.badDescriptor)
                }
                
                let item = FortranFile.Format.FormatItem.descriptor(
                    descriptor: descriptor,
                    repeatCount: repeatCount)
                
                items.append(item)
                continue
            }
            
            if let commandType = commands[code] {
                guard let command = commandType.init(
                    prefix: repeatCount,
                    formatWords: remaining)
                else {
                    throw error(.badDescriptor)
                }
                
                let item = FortranFile.Format.FormatItem.command(
                    command: command)
                
                items.append(item)
                continue
            }
            
            throw error(.expectedDescriptor)
        }
        
        return FortranFile.Format(items: items)
    }
    
    private static func aggregateIntoUnits(_ words: [Word]) -> [FormatUnit] {
        var tokens = [FormatUnit]()
        var tokenWords = [Word]()
        
        func consume() {
            guard let offset = tokenWords.first?.offset else { return }
            tokens.append((offset, tokenWords.map { word in word.content }))
            tokenWords = []
        }
        
        for word in words {
            if word.content == "," || word.content == " " {
                consume()
                continue
            }
            
            tokenWords.append(word)
        }
        
        consume()

        return tokens
    }
    
    private static func splitIntoWords(_ string: String) -> [Word] {
        var words = [Word]()
        var last: Character?
        var chars = [Character]()
        var wordOffset = string.startIndex
        var currentOffset = string.startIndex
        
        func consume() {
            guard !chars.isEmpty else { return }
            let word = (wordOffset, chars.concatenated())
            words.append(word)
            chars = []
            wordOffset = currentOffset
        }
        
        for char in string {
            defer {
                chars.append(char)
                last = char
                currentOffset = string.index(after: currentOffset)
            }
            
            var isWordStart = char == "," || char == " " || char == "."
            
            if char.isLetter, let last = last, !last.isLetter {
                isWordStart = true
            }
            
            if char.isNumber, let last = last, !last.isNumber {
                isWordStart = true
            }
            
            if isWordStart {
                consume()
            }
        }
        
        consume()
        
        return words
    }
    
}
