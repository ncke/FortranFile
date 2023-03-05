//
//  IIntegerDescriptor.swift
//  
//
//  Created by Nick on 26/02/2023.
//

import Foundation

struct IIntegerDescriptor: Descriptor {

    typealias Output = FortranInteger
    
    let repeats: Int
    
    let width: Int
    
    let canCommaTerminate = true
    
    init?(prefixNumber: Int?, trailingWords: [String]) {
        guard let width = Self.widthFromTrailers(trailingWords),
              trailingWords.count == 1
        else {
            return nil
        }
        
        self.repeats = prefixNumber ?? 1
        self.width = width
    }
    
    func describe(input: String, context: inout ReadingContext) -> FortranInteger? {
        guard let integer = Int(input) else { return nil }
        return FortranInteger(value: integer)
    }
  
}
