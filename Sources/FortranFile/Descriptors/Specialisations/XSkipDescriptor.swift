//
//  File.swift
//  
//
//  Created by Nick on 28/02/2023.
//

import Foundation

struct XSkipDescriptor: Descriptor {

    typealias Output = Never
    
    let repeats: Int
    
    let width: Int
    
    let canCommaTerminate = false
    
    init?(prefixNumber: Int?, trailingWords: [String]) {
        guard let prefixNumber = prefixNumber, trailingWords.isEmpty else {
            return nil
        }
        
        repeats = 1
        width = prefixNumber
    }
    
    func describe(input: String, context: inout ReadingContext) -> Never? {
        return nil
    }

}
