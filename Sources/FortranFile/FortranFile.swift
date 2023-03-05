// MARK: - Fortran File

public struct FortranFile {}

// MARK: - Formats

extension FortranFile {
    
    public struct Format {
        let descriptors: [any Descriptor]
        let maximumWidth: Int
        
        internal init(descriptors: [any Descriptor], maximumWidth: Int) {
            self.descriptors = descriptors
            self.maximumWidth = maximumWidth
        }
    }
    
    public static func format(from string: String) throws -> Format {
        try FormatParser.parse(formatString: string)
    }
    
}

// MARK: - Format Error

extension FortranFile {
    
    public struct FormatError: FortranFileError {

        @frozen public enum ErrorKind: String, CustomStringConvertible {
            public var description: String { self.rawValue }
            case badDescriptor = "Bad descriptor definition"
            case expectedDescriptor = "Expected a descriptor"
            case internalError = "Internal error"
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
    
    public struct ReadingConfiguration {
        public static let common = ReadingConfiguration()
        public var defaultZeroiseBlanks = false
        public var shouldAllowCommaTermination = false
    }
    
    public static func read(
        input: String,
        using format: Format,
        configuration: ReadingConfiguration = ReadingConfiguration.common
    ) throws -> [any FortranValue] {
        let reader = Reader(format: format, configuration: configuration)
        return try reader.read(input: input)
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

// MARK: - Fortran Values

public protocol FortranValue {
    associatedtype T
    var value: T { get }
}

@frozen public struct FortranDouble: FortranValue {
    public typealias T = Double
    public let value: Double
}

@frozen public struct FortranInteger: FortranValue {
    public typealias T = Int
    public let value: Int
}

@frozen public struct FortranLogical: FortranValue {
    public typealias T = Bool
    public let value: Bool
}

@frozen public struct FortranString: FortranValue {
    public typealias T = String
    public let value: String
}

@frozen public struct FortranArray: FortranValue {
    public typealias T = [any FortranValue]
    public let value: T
    
    @inlinable public subscript(index: Int) -> any FortranValue {
        get { value[index] }
    }
}
