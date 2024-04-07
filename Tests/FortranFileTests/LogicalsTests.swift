import XCTest
@testable import FortranFile

final class LogicalsTests: XCTestCase {

    func testLogicals() throws {
        
        let f1 = try! FortranFile.format(from: "l1 l1 l1 3l6 l2 l2")
        let s1 = "TFt.FALSE .TRUE    .Ft  t"
        let r1 = try! FortranFile.read(input: s1, using: f1)
        
        XCTAssertEqual(r1.count, 6)
        
        
        
        
        
    }



}
