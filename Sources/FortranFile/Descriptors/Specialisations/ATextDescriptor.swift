import Foundation

struct ATextDescriptor: Descriptor {
    
    typealias Output = FortranString
    
    let repeats: Int?
    
    let width: Int
    
    let canCommaTerminate = false
    
    init?(prefixNumber: Int?, trailingWords: [String]) {
        guard
            let width = Self.widthFromTrailers(trailingWords),
            width > 0,
            trailingWords.count == 1
        else {
            return nil
        }
        
        repeats = prefixNumber
        self.width = width
    }
    
    func execute(
        input: inout ContiguousArray<CChar>,
        len: Int,
        output: inout [any FortranValue],
        context: inout ReadingContext
    ) throws {
        guard let str = Self.reassemble(&input) else {
            throw ReadFailure.propagate(.internalError)
        }
        
        let result = FortranString(value: str)
        output.append(result)
    }
    
}
