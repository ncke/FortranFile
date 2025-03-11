// MARK: - Fortran File

public struct FortranFile {}





// MARK: - Reading

extension FortranFile {
    

    
    public static func read(
        input: String,
        using format: Format,
        configuration: ReadingConfiguration = ReadingConfiguration.common
    ) throws -> [any Value] {
        let reader = Reader(format: format, configuration: configuration)
        return try reader.read(input: input)
    }
    
}




