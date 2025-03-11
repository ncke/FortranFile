import Foundation

// MARK: - ReadingConfiguration

extension FortranFile {

    public struct ReadingConfiguration: Sendable {
        public static let common = ReadingConfiguration()
        public var defaultZeroiseBlanks = false
        public var shouldAllowCommaTermination = false
        public var shouldFlattenArrays = false
    }

}
