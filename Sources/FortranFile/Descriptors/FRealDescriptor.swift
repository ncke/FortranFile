//
//  FRealDescriptor.swift
//  
//
//  Created by Nick on 28/02/2023.
//

import Foundation

struct FRealDescriptor: Descriptor {
    typealias Output = FortranDouble
    
    let canCommaTerminate = true
    let width: Int
    let decimals: Int
    
    init?(formatWords: [String]) {
        guard
            let widthWord = formatWords.first,
            let width = Int(widthWord),
            formatWords.second == ".",
            let decimalsWord = formatWords.third,
            let decimals = Int(decimalsWord),
            formatWords.count == 3
        else {
            return nil
        }
        
        self.width = width
        self.decimals = decimals
    }
    
    func translate(from string: String) -> FortranDouble? {
        guard let real = Double(string) else {
            return nil
        }
        
        return FortranDouble(value: real)
    }
    
}
