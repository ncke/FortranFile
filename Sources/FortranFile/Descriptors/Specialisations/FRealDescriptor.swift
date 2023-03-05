//
//  FRealDescriptor.swift
//  
//
//  Created by Nick on 28/02/2023.
//

import Foundation

struct FRealDescriptor: Descriptor {
    
    typealias Output = FortranDouble
    
    let repeats: Int?
    
    let width: Int
    
    let decimals: Int
    
    let canCommaTerminate = true
    
    init?(prefixNumber: Int?, trailingWords: [String]) {
        guard let (width, decimals) = Self.widthAndDecimalsFromTrailers(trailingWords),
              trailingWords.count == 3
        else {
            return nil
        }
        
        self.repeats = prefixNumber
        self.width = width
        self.decimals = decimals
    }
    
    func execute(input: inout ContiguousArray<CChar>, len: Int, output: inout [any FortranValue], context: inout ReadingContext) {
        
    }
    
//    func describe(input: String, context: inout ReadingContext) -> FortranDouble? {
//        guard let real = Double(input) else { return nil }
//        return FortranDouble(value: real)
//    }
    
}
