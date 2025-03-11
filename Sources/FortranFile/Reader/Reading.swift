import Foundation

// MARK: - Reading

extension FortranFile {

    public static func read(
        input: String,
        using format: Format,
        configuration: ReadingConfiguration = ReadingConfiguration.common
    ) throws -> [any Value] {
        let reader = makeReader(using: format, configuration: configuration)
        return try reader.read(input: input)
    }

    public static func makeReader(
        using format: Format,
        configuration: ReadingConfiguration = ReadingConfiguration.common
    ) -> Reader {
        return Reader(format: format, configuration: configuration)
    }

}
