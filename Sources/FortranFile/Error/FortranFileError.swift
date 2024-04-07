import Foundation

// MARK: - Fortran File Error

protocol FortranFileError: Error, CustomStringConvertible {
    associatedtype ErrorKind: CustomStringConvertible
    var kind: ErrorKind { get }
    var input: String { get }
    var offset: Int { get }
    var length: Int { get }
    init(kind: ErrorKind, input: String, offset: Int, length: Int)
}

extension FortranFileError {
    
    init(kind: ErrorKind, input: String, offset: String.Index, length: Int) {
        let offInt = input.distance(from: input.startIndex, to: offset)
        self.init(kind: kind, input: input, offset: offInt, length: length)
    }
    
    public var description: String {
        let hats = String(repeating: " ", count: offset)
            + String(repeating: "^", count: length)
        
        return """
            Error parsing format: \
            \(kind) in [\(offset)...\(offset + length - 1)]
            \(input)
            \(hats)
            """
    }
    
}
