//
//  Field.swift
//  
//
//  Created by Nick on 21/02/2023.
//

import Foundation

public enum Field {
    case string(string: String)
    case integer(integer: Int)
    case double(double: Double)
    case array(fields: [Field])
    
    public func value<T>() throws -> T? {
        switch self {
            
        case .string(let string):
            guard let s = string as? T else { return nil }
            return s
            
        case .integer(let integer):
            guard let i = integer as? T else { return nil }
            return i
            
        case .double(let double):
            guard let d = double as? T else { return nil }
            return d
            
        case .array(let fields):
            guard let fs = fields as? T else { return nil }
            return fs
        }
    }
}
