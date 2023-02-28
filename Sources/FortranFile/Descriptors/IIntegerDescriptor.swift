//
//  IIntegerDescriptor.swift
//  
//
//  Created by Nick on 26/02/2023.
//

import Foundation

struct IIntegerDescriptor: Descriptor {
    typealias Output = FortranInteger
    
    let canCommaTerminate = true
    let width: Int
    
    init?(formatWords: [String]) {
        guard
            let widthWord = formatWords.first,
            let width = Int(widthWord),
            formatWords.count == 1
        else {
            return nil
        }
        
        self.width = width
    }
    
    func translate(from string: String) -> FortranInteger? {
        guard let number = Int(string) else {
            return nil
        }
        
        return FortranInteger(value: number)
    }
    
}
