import Foundation

// MARK: - Formats

extension FortranFile {

    public struct Format: Sendable {
        let descriptors: [any Descriptor]
        let maximumWidth: Int
        let expectedCapacity: Int

        internal init(
            descriptors: [any Descriptor],
            maximumWidth: Int,
            expectedCapacity: Int
        ) {
            self.descriptors = descriptors
            self.maximumWidth = maximumWidth
            self.expectedCapacity = expectedCapacity
        }
    }

    public static func format(from string: String) throws -> Format {
        try FormatParser.parse(formatString: string)
    }

}
