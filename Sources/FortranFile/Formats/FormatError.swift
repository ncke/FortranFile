//
//  FormatError.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import Foundation

// MARK: - Format Error

extension FortranFile {
    
    public struct FormatError: Error {
        
        public enum ErrorKind: CustomStringConvertible {
            case badDescriptor
            case expectedDescriptor
            case unrecognisedDescriptor
        }
        
        public let kind: ErrorKind
        public let input: String
        public let offset: Int
        public let length: Int
        
        init(
            kind: ErrorKind,
            input: String,
            offset: String.Index,
            length: Int
        ) {
            self.kind = kind
            self.input = input
            self.offset = input.distance(from: input.startIndex, to: offset)
            self.length = length
        }
        
    }
    
}

extension FortranFile.FormatError.ErrorKind {
    
    public var description: String {
        switch self {
        case .badDescriptor: return "Bad descriptor"
        case .expectedDescriptor: return "Expected descriptor"
        case .unrecognisedDescriptor: return "Unrecognised descriptor"
        }
    }
    
}

extension FortranFile.FormatError: CustomStringConvertible {
    
    public var description: String {
        let hats = String(repeating: " ", count: offset)
        + String(repeating: "^", count: length)
        
        return """
            Error parsing format: \
            \(kind) in [\(offset)...\(offset + length - 1)]
            \(input)
            \(hats)
            """
    }
    
}
