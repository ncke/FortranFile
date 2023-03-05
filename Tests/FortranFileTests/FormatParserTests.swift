//
//  FormatParserTests.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import XCTest
@testable import FortranFile

final class FormatParserTests: XCTestCase {

    func testParser() throws {

        do {
            let format = try FormatParser.parse(formatString: "1x,4i1,i5,4x,4a2,f5.2")
            print(format)
            
            let input = " 234598765    AABBCCDD12.34"
            let res = try FortranFile.read(input: input, using: format)
            
            print(res)
            print("hello")
            
            let format2 = try FormatParser.parse(formatString: "i5,bz,i5,bn,i5")
            let input2 = "  111 2 22  33  "
            
            let res2 = try FortranFile.read(input: input2, using: format2)
            
            print(res2)
            print("hello")
            
        } catch {
            print(error)
            print("hello")
        }

        
    }

}
