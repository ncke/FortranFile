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

// MARK: - Reader

struct Reader {
    let descriptors: [any Descriptor]
    let maximumWidth: Int
    let allowCommaTermination = true
    
    init(format: FortranFile.Format) {
        descriptors = format.descriptors
        maximumWidth = format.maximumWidth
    }
    
    func read(input: String) throws -> [any FortranValue] {
        var output = [any FortranValue]()
        var context = ReadingContext(input: input)
        
        var field = ContiguousArray<CChar>(
            unsafeUninitializedCapacity: maximumWidth + 1) { buffer, initializedCount in
                initializedCount = maximumWidth
            }
        
        var len = 0
        var isForcedTermination = false
        var repeatIteration: Int?
        var repeatOutput: [any FortranValue]!
        
        var descIterator = self.descriptors.makeIterator()
        guard var descriptor = descIterator.next() else { return [] }
        
        if let repeats = descriptor.repeats {
            repeatIteration = repeats
            repeatOutput = []
        }
        
    outer: for var char in input.utf8CString {
        
    inner: while isForcedTermination || len == descriptor.width {
        field[len] = 0
        
        defer {
            len = 0
            isForcedTermination = false
        }
        
        if var iteration = repeatIteration {
            descriptor.execute(
                input: &field,
                len: len,
                output: &repeatOutput,
                context: &context)
            
            iteration -= 1
            repeatIteration = iteration
            
            if iteration <= 0 {
                let fortranArray = FortranArray(value: repeatOutput)
                output.append(fortranArray)
                repeatIteration = nil
                repeatOutput = []
            } else {
                break inner
            }
            
        } else {
            descriptor.execute(
                input: &field,
                len: len,
                output: &output,
                context: &context)
        }
        
        guard let next = descIterator.next() else {
            break outer
        }
        
        descriptor = next
        
        if let repeats = next.repeats {
            repeatIteration = repeats
            repeatOutput = []
        }
    } /* inner */
        
        if allowCommaTermination && char == 44 && descriptor.canCommaTerminate {
            isForcedTermination = true
            continue outer
        }
        
        if context.shouldZeroiseBlanks && (char == 32 || char == 9) {
            char = 48
        }
        
        field[len] = char
        len += 1
        
    } /* outer */
        
        return output
    }
    
}
