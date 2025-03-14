import Foundation

struct PScaleFactorDescriptor: Descriptor {
    
    typealias Output = Never
    
    let repeats: Int?
    
    let width: Int
    
    let canCommaTerminate = false
    
    let scaleFactor: Int
    
    init?(prefixNumber: Int?, trailingWords: [String]) {
        guard
            let factor = prefixNumber,
            trailingWords.isEmpty
        else {
            return nil
        }
        
        self.repeats = nil
        self.width = 0
        self.scaleFactor = factor
    }
    
    func execute(
        input: inout ContiguousArray<CChar>,
        len: Int,
        output: inout [any FortranFile.Value],
        context: inout ReadingContext
    ) throws {
        context.scaleFactor = scaleFactor
    }
    
}
