import Foundation

struct BZBlanksZeroiseDescriptor: Descriptor {
    
    typealias Output = Never
    
    let repeats: Int?
    
    let width: Int
    
    let canCommaTerminate = false
    
    init?(prefixNumber: Int?, trailingWords: [String]) {
        guard
            prefixNumber == nil,
            trailingWords.count == 0
        else {
            return nil
        }
        
        self.repeats = nil
        self.width = 0
    }
    
    func execute(
        input: inout ContiguousArray<CChar>,
        len: Int,
        output: inout [any FortranValue],
        context: inout ReadingContext
    ) throws {
        context.activeZeroiseBlanks = true
    }
    
}
