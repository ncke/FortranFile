import Foundation

// MARK: - Reading Context

class ReadingContext {
    var defaultZeroiseBlanks: Bool
    var activeZeroiseBlanks: Bool
    var scaleFactor: Int
    
    init(defaultZeroiseBlanks: Bool, scaleFactor: Int) {
        self.defaultZeroiseBlanks = defaultZeroiseBlanks
        self.activeZeroiseBlanks = defaultZeroiseBlanks
        self.scaleFactor = scaleFactor
    }
}

// MARK: - Reader

public struct Reader: Sendable {
    let descriptors: [any Descriptor]
    let maximumWidth: Int
    let expectedCapacity: Int
    public let configuration: FortranFile.ReadingConfiguration

    init(
        format: FortranFile.Format,
        configuration: FortranFile.ReadingConfiguration
    ) {
        self.descriptors = format.descriptors
        self.maximumWidth = format.maximumWidth
        self.expectedCapacity = format.expectedCapacity
        self.configuration = configuration
    }
    
}

// MARK: - Read

extension Reader {
    
    public func read(input: String) throws -> [any FortranFile.Value] {
        var output = [any FortranFile.Value]()
        output.reserveCapacity(expectedCapacity)
        
        var context = ReadingContext(
            defaultZeroiseBlanks: configuration.defaultZeroiseBlanks,
            scaleFactor: 0)
        
        var field = ContiguousArray<CChar>(
            unsafeUninitializedCapacity: maximumWidth + 1
        ) {
            _, initializedCount in
            initializedCount = maximumWidth + 1
        }
        
        var len = 0
        var readOffset = 0
        let flattenArrays = configuration.shouldFlattenArrays
        let allowCommaTermination = configuration.shouldAllowCommaTermination
        var isForcedTermination = false
        var repeatIteration: Int?
        var repeatOutput: [any FortranFile.Value]!

        var descIterator = self.descriptors.makeIterator()
        guard var descriptor = descIterator.next() else { return [] }
        
        if let repeats = descriptor.repeats {
            repeatIteration = repeats
            repeatOutput = []
        }
        
        do {
            
        outer: for var char in input.utf8CString {
            
        inner: while isForcedTermination || len == descriptor.width {
            field[len] = 0
            
            defer {
                len = 0
                isForcedTermination = false
            }
            
            if var iteration = repeatIteration {
                try descriptor.execute(
                    input: &field,
                    len: len,
                    output: &repeatOutput,
                    context: &context)
                
                iteration -= 1
                repeatIteration = iteration
                
                if iteration <= 0 {

                    if flattenArrays {
                        output += repeatOutput
                    } else {
                        let fortranArray = FortranFile.FortranArray(
                            value: repeatOutput)
                        output.append(fortranArray)
                    }

                    repeatIteration = nil
                } else {
                    break inner
                }
                
            } else {
                try descriptor.execute(
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
                repeatOutput.reserveCapacity(repeats)
            }
            
        } /* inner */
            
            readOffset += 1
            
            if context.activeZeroiseBlanks && (char == 32 || char == 9) {
                char = 48 /* 0 */
            }
            
            if allowCommaTermination
                && char == 44 /* , */
                && descriptor.canCommaTerminate
            {
                isForcedTermination = true
                continue outer
            }
            
            field[len] = char
            len += 1
            
        } /* outer */
            
        } catch ReadFailure.propagate(let kind) {
            let errorLength = max(1, descriptor.width)
            let errorOffset = readOffset - descriptor.width
            
            throw FortranFile.ReadError(
                kind: kind,
                input: input,
                offset: errorOffset,
                length: errorLength)
            
        } /* do */
        
        return output
    }
    
}

// MARK: - Read Failure

enum ReadFailure: Error {
    case propagate(_ kind: FortranFile.ReadError.ErrorKind)
}
