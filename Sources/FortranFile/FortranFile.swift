// MARK: - Fortran File

public struct FortranFile {}

// MARK: - Formats

extension FortranFile {
    
    public struct Format {
        var descriptors: [any Descriptor]
    }
    
    public static func format(from string: String) throws -> Format {
        try FormatParser.parse(formatString: string)
    }
    
}

// MARK: - Format Error

extension FortranFile {
    
    public struct FormatError: FortranFileError {

        public enum ErrorKind: String, CustomStringConvertible {
            public var description: String { self.rawValue }
            case badDescriptor = "Bad descriptor"
            case expectedDescriptor = "Expected a descriptor"
            case unrecognisedDescriptor = "Unrecognised descriptor"
        }
        
        public let kind: ErrorKind
        public let input: String
        public let offset: Int
        public let length: Int
    }
    
}

// MARK: - Reading

extension FortranFile {
    
    public static func read(
        input: String,
        using format: Format
    ) throws -> [any FortranValue] {
        fatalError()
        
//        let reader = Reader(input: input, format: format)
//        try reader.read()
//        return reader.fields
    }
    
}

// MARK: - Read Error

extension FortranFile {
    
    public struct ReadError: FortranFileError {
        
        public enum ErrorKind: String, CustomStringConvertible {
            public var description: String { self.rawValue }
            case internalError = "Internal error"
            case expectedInteger = "Expected an integer value"
            case expectedLogical = "Expected a logical value"
            case expectedReal = "Expected a real value"
            case unexpectedDecimalPoint = "Unexpected decimal point"
        }
        
        public let kind: ErrorKind
        public let input: String
        public let offset: Int
        public let length: Int
    }
    
}
