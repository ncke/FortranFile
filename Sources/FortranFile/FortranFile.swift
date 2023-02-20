public struct FortranFile {
    
    public enum FortranError: Error {
        
    }
    
    

    public init() {
    }
    
    public static func format(string: String) throws -> FortranFile.Format {
        try FormatParser.parse(string: string)
    }
    
}
