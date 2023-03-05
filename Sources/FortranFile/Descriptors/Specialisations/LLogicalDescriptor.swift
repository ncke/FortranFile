//
//  LLogicalDescriptor.swift
//  
//
//  Created by Nick on 05/03/2023.
//

import Foundation

// MARK: - Logical Descriptor

struct LLogicalDescriptor: Descriptor {

    typealias Output = FortranLogical
    
    let repeats: Int?
    
    let width: Int
    
    let canCommaTerminate = true
    
    init?(prefixNumber: Int?, trailingWords: [String]) {
        guard let width = Self.widthFromTrailers(trailingWords),
              width > 0,
              trailingWords.count == 1
        else {
            return nil
        }
        
        self.repeats = prefixNumber
        self.width = width
    }
    
    func execute(
        input: inout ContiguousArray<CChar>,
        len: Int,
        output: inout [any FortranValue],
        context: inout ReadingContext
    ) throws {
        var read: Bool? = nil
        var metPoint = false
        
        input.withUnsafeBufferPointer { ptr in
            guard var ccScan = ptr.baseAddress else { return }
            
            while ccScan.pointee != 0 {
                if ccScan.pointee == 32 || ccScan.pointee == 9 {
                    ccScan += 1
                    continue
                }
                else if ccScan.pointee == 46 {
                    guard !metPoint else { break }
                    metPoint = true
                    ccScan += 1
                    continue
                }
                else if ccScan.pointee | 32 == 116 {
                    read = true
                }
                else if ccScan.pointee | 32 == 102 {
                    read = false
                }
                
                break
            }
        }

        guard let boolean = read else {
            throw ReadFailure.propagate(.expectedLogical)
        }
        
        let result = FortranLogical(value: boolean)
        output.append(result)
    }
  
}
