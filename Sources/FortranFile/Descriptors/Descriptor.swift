//
//  Descriptor.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import Foundation

protocol Descriptor<Output> {
    associatedtype Output
    init?(prefixNumber: Int?, trailingWords: [String])
    var repeats: Int { get }
    var width: Int { get }
    var canCommaTerminate: Bool { get }
    func describe(input: String, context: inout ReadingContext) -> Output?
}

extension Descriptor {
    
    static func widthFromTrailers(_ trailingWords: [String]) -> Int? {
        guard let firstTrailer = trailingWords.first else {
            return nil
        }
        
        return Int(firstTrailer)
    }
    
    static func widthAndDecimalsFromTrailers(_ trailingWords: [String]) -> (Int, Int)? {
        guard let width = widthFromTrailers(trailingWords),
              let point = trailingWords.second,
              point == ".",
              let decimalsTrailer = trailingWords.third,
              let decimals = Int(decimalsTrailer)
        else {
            return nil
        }
        
        return (width, decimals)
    }
    
}
