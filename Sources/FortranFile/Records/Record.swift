//
//  Record.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import Foundation

// MARK: - Record

extension FortranFile {
    
    public typealias Record = [Field]
        
    public enum Field {
        case string(string: String)
        case integer(integer: Int)
        case double(double: Double)
        case array(fields: [Field])
        
        public func value<T>() throws -> T {
            switch self {
                
            case .string(let string):
                guard let s = string as? T else {
                    throw RecordError.typeMismatch
                }
                return s
                
            case .integer(let integer):
                guard let i = integer as? T else {
                    throw RecordError.typeMismatch
                }
                return i
                
                
            case .double(let double):
                guard let d = double as? T else {
                    throw RecordError.typeMismatch
                }
                return d
                
            case .array(let fields):
                guard let fs = fields as? T else {
                    throw RecordError.typeMismatch
                }
                return fs
            }
        }
    }

}

// MARK: - Parsing

extension FortranFile {

    public static func parse(string: String, using format: Format) -> Record {
        for item in format.items {
            
        }
    }
    
}

// MARK: - Record Error

public enum RecordError: Error {
    case typeMismatch
}
