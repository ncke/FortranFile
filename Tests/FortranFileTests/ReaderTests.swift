import Testing
@testable import FortranFile

// MARK: - ReaderTests

struct ReaderTests {

    @Test func testReadNumericsInContext() throws {
        do {
            let format = try FortranFile.format(
                from: "1x,4i1,i5,12i3,f15.11,2f18.11,f14.11,f20.11")

            let input = """
             2210    8  0  2 -3  0  0  0  0  0  0  0  0  0  \
            0.00000027809    -0.00001663913     0.00001664146 \
            4.25018630147    1577.34354244780 
            """

            let r = try FortranFile.read(input: input, using: format)
            #expect(r.count == 7)
            guard r.count == 7 else { return }

            let a1 = try #require(checkArray(r[0]))
            #expect(a1.count == 4)
            guard a1.count == 4 else { return }
            #expect(checkInteger(a1[0], is: 2))
            #expect(checkInteger(a1[1], is: 2))
            #expect(checkInteger(a1[2], is: 1))
            #expect(checkInteger(a1[3], is: 0))

            #expect(checkInteger(r[1], is: 8))

            let a2 = try #require(checkArray(r[2]))
            #expect(a2.count == 12)
            guard a2.count == 12 else { return }
            #expect(checkInteger(a2[0], is: 0))
            #expect(checkInteger(a2[1], is: 2))
            #expect(checkInteger(a2[2], is: -3))
            #expect(checkInteger(a2[3], is: 0))
            #expect(checkInteger(a2[4], is: 0))
            #expect(checkInteger(a2[5], is: 0))
            #expect(checkInteger(a2[6], is: 0))
            #expect(checkInteger(a2[7], is: 0))
            #expect(checkInteger(a2[8], is: 0))
            #expect(checkInteger(a2[9], is: 0))
            #expect(checkInteger(a2[10], is: 0))
            #expect(checkInteger(a2[11], is: 0))

            #expect(checkDouble(r[3], is: 0.00000027809))

            let a3 = try #require(checkArray(r[4]))
            #expect(a3.count == 2)
            guard a3.count == 2 else { return }
            #expect(checkDouble(a3[0], is: -0.00001663913))
            #expect(checkDouble(a3[1], is: 0.00001664146))

            #expect(checkDouble(r[5], is: 4.25018630147))
            #expect(checkDouble(r[6], is: 1577.34354244780))

        } catch {
            Issue.record(error)
        }
    }

    @Test func testReadTextInContext() throws {
        do {
            let format = try FortranFile.format(from: "2x,3a2,4x,a8")
            let input = """
              abcdef    jklmnopq
            """

            let r = try FortranFile.read(input: input, using: format)

            let a1 = try #require(checkArray(r[0]))
            #expect(a1.count == 3)
            guard a1.count == 3 else { return }
            #expect(checkString(a1[0], is: "ab"))
            #expect(checkString(a1[1], is: "cd"))
            #expect(checkString(a1[2], is: "ef"))

            #expect(checkString(r[1], is: "jklmnopq"))

        } catch {
            Issue.record(error)
        }
    }

}
