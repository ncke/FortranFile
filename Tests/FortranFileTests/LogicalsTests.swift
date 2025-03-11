import Testing
@testable import FortranFile

struct LogicalsTests {

    @Test func testLogicals() throws {
        do {
            let f1 = try FortranFile.format(from: "l1 l1 l1 3l6 l2 l2")
            let i1 = "TFt.FALSE .TRUE    .Ft  t"
            let r1 = try FortranFile.read(input: i1, using: f1)

            #expect(r1.count == 6)
            guard r1.count == 6 else { return }

            #expect(checkLogical(r1[0], is: true))
            #expect(checkLogical(r1[1], is: false))
            #expect(checkLogical(r1[2], is: true))
            #expect(checkLogical(r1[4], is: true))
            #expect(checkLogical(r1[5], is: true))

            guard let arr = r1[3] as? FortranFile.FortranArray else {
                Issue.record("Expected a FortranArray")
                return
            }

            #expect(arr.value.count == 3)
            #expect(checkLogical(arr.value[0], is: false))
            #expect(checkLogical(arr.value[1], is: true))
            #expect(checkLogical(arr.value[2], is: false))

        } catch {
            Issue.record(error)
        }
    }

}
