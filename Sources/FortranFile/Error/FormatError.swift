import Foundation

// MARK: - Format Error

extension FortranFile {

    public struct FormatError: FortranFileError, Sendable {

        @frozen public enum ErrorKind:
            String, Sendable, CustomStringConvertible
        {
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
