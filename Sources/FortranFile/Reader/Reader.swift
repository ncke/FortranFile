//
//  Reader.swift
//  
//
//  Created by Nick on 21/02/2023.
//

import Foundation

// MARK: - Reader

class Reader {
    let input: String
    let format: FortranFile.Format
    
    private var cursor = 0
    
    private var scaleFactor = 1 {
        didSet {
            actualScaleFactor = Int(
                truncating: pow(10, scaleFactor) as NSDecimalNumber)
        }
    }
    private var actualScaleFactor = 1
    
    private var defaultBlankEditing: BlankEditing = .ignore
    private var currentBlankEditing: BlankEditing
    
    private(set) var fields = [Field]()
    
    init(input: String, format: FortranFile.Format) {
        self.input = input
        self.format = format
        self.currentBlankEditing = defaultBlankEditing
    }

}

// MARK: - Reading

extension Reader {
    
    func read() throws {
        fields = []
        
        for item in format.items {
            
            if item.hasControlDescriptor {
                try handleControl(item: item)
                continue
            }
            
            if let repeatFactor = item.repeatFactor {
                var array = [Field]()
                
                for _ in 0..<repeatFactor {
                    guard let field = try read(item: item) else {
                        break
                    }
                    array.append(field)
                }
                
                fields.append(Field(.array(fields: array)))
                continue
            }
            
            guard let field = try read(item: item) else {
                break
            }
            
            fields.append(field)
        }
    }
    
    private func read(item: FortranFile.Format.Item) throws -> Field? {
        
        switch item.descriptor {
            
        case .aTextString:
            return try handleTextual(item: item)
            
        default:
            break
        }
        
        throw internalError(item)
    }
    
}

// MARK: - Handle Numeric Descriptors

extension Reader {
    
    private func handleNumeric(item: FortranFile.Format.Item) throws -> Field? {
        
        guard let width = item.width else { throw internalError(item) }
        
        guard let (raw, wasCommaTerminated) = getRaw(
            width: width,
            allowCommaTermination: true)
        else {
            return nil
        }
        
        if item.hasIntegerDescriptor {
            let blanked = currentBlankEditing.edit(raw: raw)
            let trimmed = blanked.trimmingCharacters(
                in: .whitespacesAndNewlines)
            
            guard var integer = Int(trimmed) else {
                throw readError(item, .expectedInteger)
            }
            
            integer *= actualScaleFactor
            
            cursor += raw.count
            if wasCommaTerminated { cursor += 1 }
            
            return Field(.integer(integer: integer))
        }
        
        if item.hasRealDescriptor, let decimals = item.decimals {
            var real = try handleReal(raw: raw, decimals: decimals, item: item)
            
            real *= Double(actualScaleFactor)
            
            cursor += raw.count
            if wasCommaTerminated { cursor += 1 }
            
            return Field(.double(double: real))
        }
        
        throw internalError(item)
    }
    
    private func handleReal(
        raw: String,
        decimals: Int,
        item: FortranFile.Format.Item
    ) throws -> Double {
        let parts = raw.components(separatedBy: ".")
        guard parts.count > 0 else { return 0.0 }
        guard parts.count < 3 else {
            throw readError(item, .unexpectedDecimalPoint)
        }
        
        let blanked = currentBlankEditing.edit(raw: raw)
        var trimmed = blanked.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if parts.count == 1 {
            let fraction = trimmed.suffix(decimals)
            let remains = max(trimmed.count - fraction.count, 0)
            let integer = trimmed.prefix(remains)
            
            trimmed = fraction + "." + integer
        }
        
        guard let real = Double(trimmed) else {
            throw readError(item, .expectedReal)
        }
        
        return real
    }
    
}

// MARK: - Blank Editing

extension Reader {
    
    private enum BlankEditing {
        case ignore, zero
        
        func edit(raw: String) -> String {
            var edited = String()
            var isLeading = true
            for ch in raw {
                let isBlank = ch == " "
                
                if isLeading || !isBlank { edited += String(ch) }
                if !isBlank {
                    isLeading = false
                    continue
                }
                
                if self == .ignore { continue }
                
                edited += "0"
            }
            
            return edited
        }
    }
    
}

// MARK: - Handle Text Descriptor

extension Reader {
    
    private func handleTextual(
        item: FortranFile.Format.Item
    ) throws -> Field? {
        
        guard
            item.descriptor == FortranFile.Format.Descriptor.aTextString,
            let width = item.width
        else {
            throw internalError(item)
        }
        
        guard let (text, _) = getRaw(
            width: width,
            allowCommaTermination: false)
        else {
            return nil
        }
        
        cursor += text.count
        return Field(.string(string: text))
    }
    
}

// MARK: - Handle Control Descriptors

extension Reader {
    
    private func handleControl(item: FortranFile.Format.Item) throws {
        switch item.descriptor {
            
        case .pScaleFactor:
            guard let factor = item.repeatFactor else { break }
            scaleFactor = factor
            return
            
        case .xHorizontalSkip:
            guard let factor = item.repeatFactor else { break }
            cursor += factor
            return
            
        case .bBlanksDefault:
            currentBlankEditing = defaultBlankEditing
            return
            
        case .bnBlanksIgnore:
            currentBlankEditing = .ignore
            return
            
        case .bzBlanksZero:
            currentBlankEditing = .zero
            return
            
        default:
            break
        }
        
        throw internalError(item)
    }
    
}

// MARK: - String Extraction

extension Reader {
    
    private func getRaw(
        width: Int,
        allowCommaTermination: Bool
    ) -> (String, Bool)? {
        
        guard let startIndex = input.index(
            input.startIndex,
            offsetBy: cursor,
            limitedBy: input.endIndex)
        else {
            return nil
        }
        
        let endIndex = input.index(
            input.startIndex,
            offsetBy: cursor + width,
            limitedBy: input.endIndex
        ) ?? input.endIndex
        
        let fragment = input[startIndex..<endIndex]

        guard
            allowCommaTermination,
            let commaIndex = fragment.firstIndex(where: { c in c == "," })
        else {
            return (String(fragment), false)
        }
        
        let subFragment = fragment[fragment.startIndex..<commaIndex]
        return (String(subFragment), true)
    }
    
}

// MARK: - Format Item Helpers

fileprivate extension FortranFile.Format.Item {
    
    var hasControlDescriptor: Bool {
        switch self.descriptor {
        case .xHorizontalSkip,
             .pScaleFactor,
             .bBlanksDefault,
             .bnBlanksIgnore,
             .bzBlanksZero: return true
        default: return false
        }
    }
    
    var hasIntegerDescriptor: Bool {
        self.descriptor == .iInteger
    }
    
    var hasRealDescriptor: Bool {
        self.descriptor == .dDoublePrecision
        || self.descriptor == .eRealExponent
        || self.descriptor == .fRealFixedPoint
        || self.descriptor == .gRealDecimal
    }
    
}

// MARK: - Read Errors

extension Reader {
    
    private func internalError(
        _ item: FortranFile.Format.Item
    ) -> FortranFile.ReadError {
        
        return FortranFile.ReadError(
            kind: .internalError,
            offset: cursor,
            length: item.width ?? 1)
    }
    
    private func readError(
        _ item: FortranFile.Format.Item,
        _ kind: FortranFile.ReadError.ErrorKind
    ) -> FortranFile.ReadError {
        
        return FortranFile.ReadError(
            kind: kind,
            offset: cursor,
            length: item.width ?? 1)
    }
    
}
