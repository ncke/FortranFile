//
//  Record.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import Foundation

// MARK: - Record

extension FortranFile {
    
    public struct Record {
        
        public enum Field {
            case string(string: String)
            case integer(integer: Int)
            case double(double: Double)
            case array(fields: [Field])
            
            public func value<T>() throws -> T? {
                switch self {
                    
                case .string(let string):
                    guard let s = string as? T else { return nil }
                    return s
                    
                case .integer(let integer):
                    guard let i = integer as? T else { return nil }
                    return i
                    
                case .double(let double):
                    guard let d = double as? T else { return nil }
                    return d
                    
                case .array(let fields):
                    guard let fs = fields as? T else { return nil }
                    return fs
                }
            }
        }
        
        let fields: [Field]
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

// MARK: - Record Parsing

extension FortranFile.Record {
    
    class ParseInfo {
        var cursor = 0
        var scaleFactor = 1
    }
    
    public static func parse(
        input: String,
        using format: FortranFile.Format
    ) throws -> FortranFile.Record {
        var fields = [FortranFile.Record.Field]()
        var info = ParseInfo()
        
        for item in format.items {
            
            if item.hasControlDescriptor {
                try handleControl(input: input, item: item, info: &info)
                continue
            }
            
            if let repeatFactor = item.repeatFactor {
                var array = [FortranFile.Record.Field]()
                
                for _ in 0..<repeatFactor {
                    guard let field = try parse(
                        input: input,
                        item: item,
                        info: &info)
                    else {
                        break
                    }
                    array.append(field)
                }
                
                fields.append(FortranFile.Record.Field.array(fields: array))
                continue
            }
            
            guard let field = try parse(
                input: input,
                item: item,
                info: &info)
            else {
                break
            }
            
            fields.append(field)
        }
        
        return FortranFile.Record(fields: fields)
    }
    
    static func parse(
        input: String,
        item: FortranFile.Format.Item,
        info: inout ParseInfo
    ) throws -> FortranFile.Record.Field? {
        
        switch item.descriptor {
            
        case .aTextString:
            return try handleTextual(input: input, item: item, info: &info)
            
        default:
            break
        }
        
        throw internalError(item, info)
    }
    
}

// MARK: - Handle Numeric Descriptors

extension FortranFile.Record {
    
    
    
    
}

// MARK: - Handle Text Descriptor

extension FortranFile.Record {
    
    static func handleTextual(
        input: String,
        item: FortranFile.Format.Item,
        info: inout ParseInfo
    ) throws -> FortranFile.Record.Field? {
        
        guard item.descriptor == .aTextString, let width = item.width else {
            throw internalError(item, info)
        }
        
        guard let (text, _) = take(
            input: input,
            offset: info.cursor,
            width: width,
            allowCommaTermination: false)
        else {
            return nil
        }
        
        info.cursor += text.count
        return .string(string: text)
    }
    
}

// MARK: - Handle Control Descriptors

extension FortranFile.Record {
    
    static func handleControl(
        input: String,
        item: FortranFile.Format.Item,
        info: inout ParseInfo
    ) throws {
        
        switch item.descriptor {
            
        case .pScaleFactor:
            guard let factor = item.repeatFactor else { break }
            info.scaleFactor = factor
            return
            
        case .xHorizontalSkip:
            guard let factor = item.repeatFactor else { break }
            info.cursor += factor
            return
            
        default:
            break
        }
        
        throw internalError(item, info)
    }
    
    static func internalError(
        _ item: FortranFile.Format.Item,
        _ info: ParseInfo
    ) -> FortranFile.RecordError {
        
        return FortranFile.RecordError.make(
            kind: .internalError,
            item: item,
            info: info)
    }
    
}

// MARK: - String Extraction

extension FortranFile.Record {
    
    static func take(
        input: String,
        offset: Int,
        width: Int,
        allowCommaTermination: Bool
    ) -> (String, Bool)? {
        
        guard let startIndex = input.index(
            input.startIndex,
            offsetBy: offset,
            limitedBy: input.endIndex)
        else {
            return nil
        }
        
        let endIndex = input.index(
            input.startIndex,
            offsetBy: offset + width,
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

// MARK: - Record Error

extension FortranFile {
    
    public struct RecordError: Error {
        
        public enum ErrorKind {
            case internalError
        }
        
        let kind: ErrorKind
        let offset: Int
        let length: Int
    }
    
}

extension FortranFile.RecordError {
    
    static func make(
        kind: ErrorKind,
        item: FortranFile.Format.Item,
        info: FortranFile.Record.ParseInfo
    ) -> FortranFile.RecordError {
        
        let error = FortranFile.RecordError(
            kind: kind,
            offset: info.cursor,
            length: item.width ?? 1)
        
        return error
    }
    
}
