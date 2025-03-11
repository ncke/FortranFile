import Foundation

// MARK: - Parser

class FormatParser {
    
    static func parse(formatString: String) throws -> FortranFile.Format {
        let tokens = try FormatTokeniser.tokenise(formatString: formatString)
        
        let descriptors = try tokens.map { token in
            switch token.parse() {
            case .success(let item):
                return item
            case .failure(let kind):
                throw FortranFile.FormatError(
                    kind: kind,
                    input: formatString,
                    offset: token.tokenOffset,
                    length: token.tokenLength)
            }
        }
        
        let maximumWidth = descriptors.map { desc in desc.width }.max() ?? 0
        
        let expectedCapacity = descriptors
            .filter { desc in desc.width > 0 }
            .count
        
        return FortranFile.Format(
            descriptors: descriptors,
            maximumWidth: maximumWidth,
            expectedCapacity: expectedCapacity)
    }
    
}

fileprivate extension FormatTokeniser.Token {
    
    private static let codeMap: [String: any Descriptor.Type] = [
        "A":    ATextDescriptor.self,
        "B":    BBlanksDefaultDescriptor.self,
        "BN":   BNBlanksIgnoreDescriptor.self,
        "BZ":   BZBlanksZeroiseDescriptor.self,
        "F":    FRealDescriptor.self,
        "I":    IIntegerDescriptor.self,
        "L":    LLogicalDescriptor.self,
        "P":    PScaleFactorDescriptor.self,
        "X":    XSkipDescriptor.self
    ]
    
    enum ParsingOutcome {
        case success(_ desc: any Descriptor)
        case failure(_ kind: FortranFile.FormatError.ErrorKind)
    }

    func parse() -> ParsingOutcome {
        guard let code = code else {
            return .failure(.expectedDescriptor)
        }
        
        guard let type = Self.codeMap[code] else {
            return .failure(.unrecognisedDescriptor)
        }
        
        guard let desc = type.init(
            prefixNumber: prefixNumber,
            trailingWords: content)
        else {
            return .failure(.badDescriptor)
        }
        
        return .success(desc)
    }
    
}
