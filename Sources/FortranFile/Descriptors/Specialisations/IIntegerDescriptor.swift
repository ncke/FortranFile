//
//  IIntegerDescriptor.swift
//  
//
//  Created by Nick on 26/02/2023.
//

import Foundation

struct IIntegerDescriptor: Descriptor {

    typealias Output = FortranInteger
    
    let repeats: Int?
    
    let width: Int
    
    let canCommaTerminate = true
    
    init?(prefixNumber: Int?, trailingWords: [String]) {
        guard let width = Self.widthFromTrailers(trailingWords),
              trailingWords.count == 1
        else {
            return nil
        }
        
        self.repeats = prefixNumber
        self.width = width
    }
    
    func execute(
        input: inout ContiguousArray<CChar>,
        len: Int,
        output: inout [any FortranValue],
        context: inout ReadingContext
    ) {
        let (str, err) = Self.reassemble(&input, trimming: true)
        
        if let errorKind = err {
            fatalError()
        }
        
        guard let str = str else {
            fatalError()
        }
        
        guard let integer = Int(str) else {
            fatalError()
        }
        
        let result = FortranInteger(value: integer)
        output.append(result)
    }
    
//    func describe(input: String, context: inout ReadingContext) -> FortranInteger? {
//        guard let integer = Int(input) else { return nil }
//        return FortranInteger(value: integer)
//    }
  
}
