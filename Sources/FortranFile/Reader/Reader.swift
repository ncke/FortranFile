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
    private var scaleFactor = 1
    private(set) var fields = [Field]()
    
    init(input: String, format: FortranFile.Format) {
        self.input = input
        self.format = format
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
                
                fields.append(Field.array(fields: array))
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
        return .string(string: text)
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
        case .xHorizontalSkip, .pScaleFactor: return true
        default: return false
        }
    }
    
}

// MARK: - Internal Error

extension Reader {
    
    private func internalError(
        _ item: FortranFile.Format.Item
    ) -> FortranFile.ReadError {
        
        return FortranFile.ReadError(
            kind: .internalError,
            offset: cursor,
            length: item.width ?? 1)
    }
    
}
