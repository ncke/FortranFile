//
//  File.swift
//  
//
//  Created by Nick on 28/02/2023.
//

import Foundation

struct XSkipDescriptor: Descriptor {

    typealias Output = Never
    
    let repeats: Int? = nil
    
    let width: Int
    
    let canCommaTerminate = false
    
    init?(prefixNumber: Int?, trailingWords: [String]) {
        guard
            let prefixNumber = prefixNumber,
            prefixNumber > 0,
            trailingWords.isEmpty
        else {
            return nil
        }
        
        width = prefixNumber
    }
    
    func execute(
        input: inout ContiguousArray<CChar>,
        len: Int,
        output: inout [any FortranValue],
        context: inout ReadingContext
    ) {
        // Skip is a no-op.
    }

}
