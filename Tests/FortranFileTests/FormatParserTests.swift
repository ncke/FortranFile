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
            let format = try FormatParser.parse(formatString: "1x,4i1,i5,12i3,f15.11,2f18.11,f14.11,f20.11")
            //print(format)
            //print("hello")
        } catch {
            print(error)
            //print("hello")
        }

        
    }

}
