import Foundation

// MARK: - Descriptor

protocol Descriptor<Output> {
    associatedtype Output
    
    var repeats: Int? { get }
    var width: Int { get }
    var canCommaTerminate: Bool { get }
    
    init?(prefixNumber: Int?, trailingWords: [String])
    
    func execute(
        input: inout ContiguousArray<CChar>,
        len: Int,
        output: inout [any FortranFile.Value],
        context: inout ReadingContext
    ) throws
}

// MARK: - Format Parsing Helpers

extension Descriptor {
    
    static func widthFromTrailers(_ trailingWords: [String]) -> Int? {
        guard let firstTrailer = trailingWords.first else {
            return nil
        }
        
        return Int(firstTrailer)
    }
    
    static func widthAndDecimalsFromTrailers(
        _ trailingWords: [String]
    ) -> (Int, Int)? {
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
    ) -> String? {
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

            str = String(validatingCString: ccBase)
        }
        
        return str
    }
    
    static func reassembleRealParts(
        _ input: inout ContiguousArray<CChar>
    ) -> (String?, String?, Bool) {
        var real: String? = nil
        var expo: String? = nil
        var hasPoint: Bool = false
        
        input.withUnsafeMutableBufferPointer { ptr in
            guard var ccBase = ptr.baseAddress else {
                return
            }
            
            while ccBase.pointee == 32 || ccBase.pointee == 9 {
                ccBase += 1
            }
            
            var isInsideExponent = false
            var ccScan = ccBase
            
            while ccScan.pointee != 0 {
                if ccScan.pointee | 32 == 101 /* E or e */ {
                    isInsideExponent = true
                    ccScan.pointee = 0
                    real = String(validatingCString: ccBase)
                    ccBase = ccScan + 1
                } else if !isInsideExponent && ccScan.pointee == 46 /* . */ {
                    hasPoint = true
                }
                
                ccScan += 1
            }
            
            if isInsideExponent {
                expo = String(validatingCString: ccBase)
            } else {
                real = String(validatingCString: ccBase)
            }
        }
        
        return (real, expo, hasPoint)
    }
    
}
