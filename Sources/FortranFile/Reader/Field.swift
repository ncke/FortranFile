//
//  Field.swift
//  
//
//  Created by Nick on 21/02/2023.
//

import Foundation

public struct Field {
    
    enum FieldValue {
        case string(string: String)
        case integer(integer: Int)
        case double(double: Double)
        case array(fields: [Field])
    }
    
    var fieldValue: FieldValue
    
    init(_ fieldValue: FieldValue) {
        self.fieldValue = fieldValue
    }
    
    public func value<T>() throws -> T? {
        switch self.fieldValue {
            
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
