//
//  ATextDescriptor.swift
//  
//
//  Created by Nick on 26/02/2023.
//

import Foundation

struct ATextDescriptor: Descriptor {
    
    typealias Output = FortranString
    
    let repeats: Int
    
    let width: Int
    
    let canCommaTerminate = false
    
    init?(prefixNumber: Int?, trailingWords: [String]) {
        guard
            let width = Self.widthFromTrailers(trailingWords),
            trailingWords.count == 1
        else {
            return nil
        }
        
        repeats = prefixNumber ?? 1
        self.width = width
    }
    
    func describe(input: String, context: inout ReadingContext) -> FortranString? {
        return FortranString(value: input)
    }
    
}
