//
//  ATextDescriptor.swift
//  
//
//  Created by Nick on 26/02/2023.
//

import Foundation

struct ATextDescriptor: Descriptor {
    typealias Output = FortranString
    
    let canCommaTerminate = false
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
    
    func translate(from string: String) -> FortranString? {
        return FortranString(value: string)
    }
    
}
