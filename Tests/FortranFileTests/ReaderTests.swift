import XCTest
@testable import FortranFile

final class ReaderTests: XCTestCase {

//    func testExample() throws {
//        let format = try FortranFile.format(
//            string: "1x,4i1,i5,12i3,f15.11,2f18.11,f14.11,f20.11")
//        
//        let input = " 2210    8  0  2 -3  0  0  0  0  0  0  0  0  0  0.00000027809    -0.00001663913     0.00001664146 4.25018630147    1577.34354244780 "
//        
//        do {
//            
//            let result = try FortranFile.read(input: input, using: format)
//            
//            print(result)
//            
//            print("hello")
//            
//        } catch let error as FortranFile.ReadError {
//            print(error)
//            print("hello")
//        }
//    }
//    
//    func testLogicals() throws {
//        let format = try FortranFile.format(string: "i4, l5, l3, l1, l2")
//        let input1 = "1234.TRUE .FT T"
//        let result1 = try FortranFile.read(input: input1, using: format)
//        
//        XCTAssertTrue(result1[1].value as! Bool)
//        XCTAssertFalse(result1[2].value as! Bool)
//        XCTAssertTrue(result1[3].value as! Bool)
//        XCTAssertTrue(result1[4].value as! Bool)
//        
//        let bad = "1234.TRUE X T T"
//        XCTAssertThrowsError(
//            try FortranFile.read(input: bad, using: format)
//        ) {
//            error in
//            
//            XCTAssertTrue(
//                (error as! FortranFile.ReadError).kind == .expectedLogical)
//        }
//    }

}
