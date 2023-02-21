//
//  ReadError.swift
//  
//
//  Created by Nick on 21/02/2023.
//

import Foundation

// MARK: - Read Error

extension FortranFile {
    
    public struct ReadError: Error {
        
        public enum ErrorKind {
            case internalError
            case expectedInteger
            case expectedLogical
            case expectedReal
            case unexpectedDecimalPoint
        }
        
        public let kind: ErrorKind
        public let input: String
        public let offset: Int
        public let length: Int
    }
    
}

extension FortranFile.ReadError.ErrorKind {
    
    public var description: String {
        switch self {
        case .expectedReal: return "Expected real"
        case .expectedLogical: return "Expected logical"
        case .expectedInteger: return "Expected integer"
        case .unexpectedDecimalPoint: return "Unexpected decimal point"
        case .internalError: return "Internal error"
        }
    }
    
}

extension FortranFile.ReadError: CustomStringConvertible {
    
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
