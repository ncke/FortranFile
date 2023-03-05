//
//  Descriptor.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import Foundation

// MARK: - Descriptor

protocol Descriptor<Output> {
    associatedtype Output
    init?(prefixNumber: Int?, trailingWords: [String])
    var repeats: Int? { get }
    var width: Int { get }
    var canCommaTerminate: Bool { get }
    func execute(input: inout ContiguousArray<CChar>, len: Int, output: inout [any FortranValue], context: inout ReadingContext)
    //func describe(input: String, context: inout ReadingContext) -> Output?
}

// MARK: - Format Parsing Helpers

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

// MARK: - Reading Helpers

extension Descriptor {
    
    static func reassemble(
        _ input: inout ContiguousArray<CChar>,
        trimming: Bool = false
    ) -> (String?, FortranFile.ReadError.ErrorKind?) {
        var str: String? = nil
        
        input.withUnsafeBufferPointer { ptr in
            guard var ccBase = ptr.baseAddress else {
                return
            }
            
            if trimming {
                while ccBase.pointee == 32 || ccBase.pointee == 9 {
                    ccBase += 1
                }
            }
            
            str = String(validatingUTF8: ccBase)
        }
        
        return (str, str != nil ? nil : .internalError)
    }

}
