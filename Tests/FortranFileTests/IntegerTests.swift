import Testing
@testable import FortranFile

struct IntegerTests {

    @Test func testIntegers() throws {
        do {
            let f1 = try FortranFile.format(from: "i2, 3x, 4i3")
            let i1 = "9983 123456789012555555555"
            let r1 = try FortranFile.read(input: i1, using: f1)

            #expect(r1.count == 2)
            guard r1.count == 2 else { return }

            #expect(checkInteger(r1[0], is: 99))

            let a1 = try #require(checkArray(r1[1]))
            #expect(a1.count == 4)
            guard a1.count == 4 else { return }
            #expect(checkInteger(a1[0], is: 123))
            #expect(checkInteger(a1[1], is: 456))
            #expect(checkInteger(a1[2], is: 789))
            #expect(checkInteger(a1[3], is: 12))

        } catch {
            Issue.record(error)
        }
    }

    @Test func testIntegerBadDescriptor() throws {
        let s = "i"

        do {
            let _ = try FortranFile.format(from: s)
            Issue.record("Expected bad descriptor error")

        } catch {
            guard let error = error as? FortranFile.FormatError else {
                Issue.record("Unexpected error type: \(error)")
                return
            }

            #expect(error.kind == .badDescriptor)
            #expect(error.input == s)
            #expect(error.offset == 0)
            #expect(error.length == 1)
        }
    }

    @Test func testIntegerBadInput() throws {
        let s = "f5.2, 3x, i5"
        let i = "12.34   99j33"

        do {
            let f = try FortranFile.format(from: s)
            let _ = try FortranFile.read(input: i, using: f)
            Issue.record("Expected read error")

        } catch {
            guard let error = error as? FortranFile.ReadError else {
                Issue.record("Unexpected error type: \(error)")
                return
            }

            #expect(error.kind == .expectedInteger)
            #expect(error.input == i)
            #expect(error.offset == 8)
            #expect(error.length == 5)
        }
    }

}
