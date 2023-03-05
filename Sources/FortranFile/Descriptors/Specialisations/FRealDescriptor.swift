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
    
    func execute(
        input: inout ContiguousArray<CChar>,
        len: Int,
        output: inout [any FortranValue],
        context: inout ReadingContext
    ) throws {
        let (rstr, estr, hasPoint) = Self.reassembleRealParts(&input)
        
        guard var realStr = rstr else {
            throw ReadFailure.propagate(.expectedReal)
        }
        
        if !hasPoint {
            let fracPart = realStr.suffix(decimals)
            let intPart = realStr.prefix(realStr.count - fracPart.count)
            realStr = intPart + "." + fracPart
        }
        
        if estr != nil || context.scaleFactor != 0 {
            
            var expo = -context.scaleFactor
            
            if let expoInputStr = estr {
                guard let expoInput = Int(expoInputStr) else {
                    throw ReadFailure.propagate(.expectedReal)
                }
                
                expo += expoInput
            }
            
            realStr += "E" + String(expo)
        }
        
        guard let value = Double(realStr) else {
            throw ReadFailure.propagate(.expectedReal)
        }
        
        let result = FortranDouble(value: value)
        output.append(result)
    }
    
}
