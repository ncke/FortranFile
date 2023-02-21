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
        }
        
        public let kind: ErrorKind
        public let offset: Int
        public let length: Int
    }
    
}
