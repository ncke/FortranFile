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
            case missingDescriptor
            case missingFieldDecimals
            case missingFieldWidth
            case descriptorIsNonRepeatable
            case unexpectedDimensions
            case unexpectedSymbols
        }
        
        public let kind: ErrorKind
        public let input: String
        public let offset: Int
        public let length: Int
    }
    
}

extension FortranFile.FormatError.ErrorKind {
    
    public var description: String {
        switch self {
        case .missingDescriptor: return "Missing descriptor"
        case .missingFieldDecimals: return "Missing field decimals"
        case .missingFieldWidth: return "Missing field width"
        case .descriptorIsNonRepeatable: return "Descriptor is non-repeatable"
        case .unexpectedDimensions: return "Unexpected dimensions"
        case .unexpectedSymbols: return "Unexpected symbols"
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
