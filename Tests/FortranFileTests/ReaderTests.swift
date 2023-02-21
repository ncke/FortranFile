//
//  ReaderTests.swift
//  
//
//  Created by Nick on 21/02/2023.
//

import XCTest
@testable import FortranFile

final class ReaderTests: XCTestCase {

    func testExample() throws {
        let format = try FortranFile.format(string: "1x,4i1,i5,12i3,f15.11,2f18.11,f14.11,f20.11")
        
        let input = " 2210    8  0  2 -3  0  0  0  0  0  0  0  0  0  0.00000027809    -0.00001663913     0.00001664146 4.25018630147    1577.34354244780 "
        
        do {
            
            let result = try FortranFile.read(input: input, using: format)
            
            print(result)
            
            print("hello")
            
        } catch let error as FortranFile.ReadError {
            print(error)
            print("hello")
        }
        

        
    }

}
