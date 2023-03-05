//
//  File.swift
//  
//
//  Created by Nick on 28/02/2023.
//

import Foundation

// MARK: - Array Destructuring

extension Array {
    
    var second: Element? { self.count > 1 ? self[1] : nil }
    
    var third: Element? { self.count > 2 ? self[2] : nil }
    
    var fourth: Element? { self.count > 3 ? self[3] : nil }
    
    mutating func takeFirst() -> Element? {
        let result = self.first
        self = Array(self.dropFirst())
        return result
    }

}


// MARK: - Character Concatenation

extension Array where Element == Character {
    
    func concatenated() -> String {
        self.reduce("") { partial, char in partial + String(char) }
    }
    
}
