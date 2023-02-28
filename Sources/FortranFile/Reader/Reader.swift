//
//  Reader.swift
//  
//
//  Created by Nick on 21/02/2023.
//

import Foundation

// MARK: - Reader

class ReadingContext {
    let input: String
    var offset: String.Index
    var shouldZeroiseBlanks = false
    var scaleFactor: Double = 1.0
    
    init(input: String) {
        self.input = input
        self.offset = input.startIndex
    }
}

