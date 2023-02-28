public struct FortranFile {
    
    public static func format(string: String) throws -> Format {
        try FormatParser.parse(formatString: string)
    }
    
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
