import Foundation

// MARK: - Read Error

extension FortranFile {

    public struct ReadError: FortranFileError, Sendable {

        public enum ErrorKind: String, Sendable, CustomStringConvertible {
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
