import Foundation

struct IIntegerDescriptor: Descriptor {

    typealias Output = FortranInteger
    
    let repeats: Int?
    
    let width: Int
    
    let canCommaTerminate = true
    
    init?(prefixNumber: Int?, trailingWords: [String]) {
        guard
            let width = Self.widthFromTrailers(trailingWords),
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
        guard let str = Self.reassemble(&input, trimming: true) else {
            throw ReadFailure.propagate(.internalError)
        }
        
        guard let integer = Int(str) else {
            throw ReadFailure.propagate(.expectedInteger)
        }
        
        let result = FortranInteger(value: integer)
        output.append(result)
    }
  
}
