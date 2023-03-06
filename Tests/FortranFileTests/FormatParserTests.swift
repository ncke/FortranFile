//
//  FormatParserTests.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import XCTest
@testable import FortranFile

final class FormatParserTests: XCTestCase {
    
    func testCorrectFormats() {
        do {
            
            let f1 = "1x,4i1,i5,4x,4a2,f5.2"
            _ = try FortranFile.format(from: f1)
            
            let f2 = "9a3,l5,f20.3"
            _ = try FortranFile.format(from: f2)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCorrectButDegenerateSpacing() {
        do {
            
            let f1 = "8f3.2  9a5  2x "
            _ = try FortranFile.format(from: f1)
            
            let f2 = "   1x"
            _ = try FortranFile.format(from: f2)
            
            let f3 = "9a5    2x "
            _ = try FortranFile.format(from: f3)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    

    func testRandomThings() throws {

        do {
            let format = try FormatParser.parse(formatString: "1x,4i1,i5,4x,4a2,f5.2")
            print(format)
            
            let input = " 234598765    AABBCCDD12.34"
            let res = try FortranFile.read(input: input, using: format)
            
            print(res)
            print("hello")
            
            let format2 = try FormatParser.parse(formatString: "i5,bz,i5,i5")
            let input2 = "  111 2 22  33  "
            
            let res2 = try FortranFile.read(input: input2, using: format2)
            
            print(res2)
            print("hello")
            
            let format3 = try FormatParser.parse(formatString: "f6.2, -2p, f6.1, f6.2")
            let input3 = "123456123456 -12.3"
            
            let res3 = try FortranFile.read(input: input3, using: format3)
            
            print(res3)
            print("hello")
            
            let format4 = try FormatParser.parse(formatString: "2x, l4, l4, l6")
            let input4 = "  .TRU  .F .FALS"
            
            let res4 = try FortranFile.read(input: input4, using: format4)
            
            print(res4)
            print("hello")
            
        } catch {
            print(error)
            print("hello")
        }

        
    }

}
