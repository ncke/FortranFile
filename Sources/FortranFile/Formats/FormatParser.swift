//
//  FormatParser.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import Foundation

// MARK: - Available Descriptors

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

// MARK: - Format Parsing

extension FormatParser {
    
    private typealias FormatUnit = (offset: String.Index, content: [String])
    
    static func parse(formatString: String) throws -> FortranFile.Format {
        var items = [FortranFile.Format.FormatItem]()
        let units = deconstruct(formatString: formatString)
        
        for unit in units {
            var remaining = unit.content
            
            func take() throws -> String {
                guard let str = remaining.first else {
                    throw makeError(.expectedDescriptor, unit, formatString)
                }
                remaining = Array(remaining.dropFirst())
                return str
            }
            
            var word = try take()
            let prefixInt = Int(word)
            if prefixInt != nil {
                word = try take()
            }
            
            if let descriptorType = descriptors[word] {
                guard let item = makeDescriptor(
                    repeatCount: prefixInt,
                    descriptorType: descriptorType,
                    formatWords: remaining)
                else {
                    throw makeError(.badDescriptor, unit, formatString)
                }
                
                items.append(item)
                continue
            }
            
            if let commandType = commands[word] {
                guard let item = makeCommand(
                    prefixInt: prefixInt,
                    commandType: commandType,
                    formatWords: remaining)
                else {
                    throw makeError(.badDescriptor, unit, formatString)
                }
                
                items.append(item)
                continue
            }
            
            throw makeError(.expectedDescriptor, unit, formatString)
        }
        
        return FortranFile.Format(items: items)
    }
    
}

// MARK: - Descriptor Constructor

extension FormatParser {
    
    private static func makeDescriptor(
        repeatCount: Int?,
        descriptorType: any Descriptor.Type,
        formatWords: [String]
    ) -> FortranFile.Format.FormatItem? {
        guard let descriptor = descriptorType.init(formatWords: formatWords)
        else {
            return nil
        }
        
        return FortranFile.Format.FormatItem.descriptor(
            descriptor: descriptor,
            repeatCount: repeatCount ?? 1)
    }
    
}

// MARK: - Command Constructor

extension FormatParser {
    
    private static func makeCommand(
        prefixInt: Int?,
        commandType: any Command.Type,
        formatWords: [String]
    ) -> FortranFile.Format.FormatItem? {
        guard let command = commandType.init(
            prefix: prefixInt,
            formatWords: formatWords)
        else {
            return nil
        }
        
        return FortranFile.Format.FormatItem.command(command: command)
    }
    
}

// MARK: - String Manipulation

extension FormatParser {
    
    private typealias Word = (offset: String.Index, content: String)
    
    private static func deconstruct(formatString: String) -> [FormatUnit] {
        let words = splitIntoWords(formatString)
        let units = aggregateIntoUnits(words)
        
        return units
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
    
}

// MARK: - Error Helper

extension FormatParser {
    
    private static func makeError(
        _ kind: FortranFile.FormatError.ErrorKind,
        _ unit: FormatUnit,
        _ formatString: String
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
    
}
