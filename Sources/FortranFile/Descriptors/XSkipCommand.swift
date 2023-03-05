//
//  File.swift
//  
//
//  Created by Nick on 28/02/2023.
//

import Foundation

struct XSkipCommand: Command {
    
    let skip: Int
    
    init?(prefix: Int?, formatWords: [String]) {
        skip = prefix ?? 1
    }
    
    func execute(context: inout ReadingContext) {
        context.offset = context.input.index(
            context.offset,
            offsetBy: skip,
            limitedBy: context.input.endIndex
        ) ?? context.input.endIndex
    }
    
}
