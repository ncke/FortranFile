import Testing
@testable import FortranFile

struct ArrayFlatteningTests {

    @Test func testFlattenArrayThreeElements() {
        do {
            let s = "a5, 1x, 3i2"
            let f = try FortranFile.format(from: s)
            let i = "abcde 123456"
            let c = FortranFile.ReadingConfiguration(shouldFlattenArrays: true)
            let r = try FortranFile.read(input: i, using: f, configuration: c)

            #expect(r.count == 4)
            guard r.count == 4 else { return }

            #expect(checkString(r[0], is: "abcde"))
            #expect(checkInteger(r[1], is: 12))
            #expect(checkInteger(r[2], is: 34))
            #expect(checkInteger(r[3], is: 56))

        } catch {
            Issue.record(error)
        }
    }

}
