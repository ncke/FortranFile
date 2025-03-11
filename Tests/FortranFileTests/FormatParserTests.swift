import Testing
@testable import FortranFile

// MARK: - Descriptor Content Check Helper

fileprivate extension Descriptor {

    func check<T>(
        is kind: T.Type,
        repeats: Int? = nil,
        width: Int? = nil,
        decimals: Int? = nil,
        canCommaTerminate comma: Bool? = nil
    ) {
        #expect(self is T)
        #expect(self.repeats == repeats)
        #expect(width == nil || self.width == width)
        #expect(comma == nil || self.canCommaTerminate == comma)

        if decimals != nil, let realDescriptor = self as? FRealDescriptor {
            #expect(realDescriptor.decimals == decimals)
        }
    }

}

// MARK: - FormatParserTests

struct FormatParserTests {

    @Test func testCorrectFormats() {
        do {
            
            let s1 = "1x,4i1,i5,4x,4a2,f5.2"
            let f1 = try FortranFile.format(from: s1)
            #expect(f1.descriptors.count == 6)
            guard f1.descriptors.count == 6 else { return }

            f1.descriptors[0].check(is: XSkipDescriptor.self, width: 1)
            f1.descriptors[1].check(is: IIntegerDescriptor.self, repeats: 4, width: 1)
            f1.descriptors[2].check(is: IIntegerDescriptor.self, width: 5)
            f1.descriptors[3].check(is: XSkipDescriptor.self, width: 4)
            f1.descriptors[4].check(is: ATextDescriptor.self, repeats: 4, width: 2)
            f1.descriptors[5].check(is: FRealDescriptor.self, width: 5, decimals: 2)

            let s2 = "9a3,l5,2f20.3"
            let f2 = try FortranFile.format(from: s2)
            #expect(f2.descriptors.count == 3)
            guard f2.descriptors.count == 3 else { return }

            f2.descriptors[0].check(is: ATextDescriptor.self, repeats: 9, width: 3)
            f2.descriptors[1].check(is: LLogicalDescriptor.self, width: 5)
            f2.descriptors[2].check(is: FRealDescriptor.self, repeats: 2, width: 20, decimals: 3)

        } catch {
            Issue.record(error)
        }
    }
    
    @Test func testCorrectButDegenerateSpacing() {
        do {
            
            let s1 = "8f3.2  9a5  2x "
            let f1 = try FortranFile.format(from: s1)
            #expect(f1.descriptors.count == 3)
            guard f1.descriptors.count == 3 else { return }

            f1.descriptors[0].check(is: FRealDescriptor.self, repeats: 8, width: 3, decimals: 2)
            f1.descriptors[1].check(is: ATextDescriptor.self, repeats: 9, width: 5)
            f1.descriptors[2].check(is: XSkipDescriptor.self, width: 2)

            let s2 = "   1x"
            let f2 = try FortranFile.format(from: s2)
            #expect(f2.descriptors.count == 1)
            guard f2.descriptors.count == 1 else { return }

            f2.descriptors[0].check(is: XSkipDescriptor.self, width: 1)

        } catch {
            Issue.record(error)
        }
    }

    @Test func testIntermingledSeparators() {
        do {

            let s1 = "i5,2x 8f3.2, 9x"
            let f1 = try FortranFile.format(from: s1)
            #expect(f1.descriptors.count == 4)
            guard f1.descriptors.count == 4 else { return }

            f1.descriptors[0].check(is: IIntegerDescriptor.self, width: 5)
            f1.descriptors[1].check(is: XSkipDescriptor.self, width: 2)
            f1.descriptors[2].check(is: FRealDescriptor.self, repeats: 8, width: 3, decimals: 2)
            f1.descriptors[3].check(is: XSkipDescriptor.self, width: 9)

        } catch {
            Issue.record(error)
        }
    }

    @Test func testBadDescriptorError() throws {
        let s1 = "a5,i,2x"

        do {
            let _ = try FortranFile.format(from: s1)
            Issue.record("Bad descriptor error was not thrown")

        } catch {
            guard let error = error as? FortranFile.FormatError else {
                Issue.record("Unexpected error type")
                return
            }

            #expect(error.kind == .badDescriptor)
            #expect(error.input == s1)
            #expect(error.offset == 3)
            #expect(error.length == 1)
        }
    }

    @Test func testExpectedDescriptorErrorForNoDescriptor() throws {
        let s1 = "a5,i5,,2x"

        do {
            let _ = try FortranFile.format(from: s1)
            Issue.record("Expected descriptor error was not thrown")

        } catch {
            guard let error = error as? FortranFile.FormatError else {
                Issue.record("Unexpected error type")
                return
            }

            #expect(error.kind == .expectedDescriptor)
            #expect(error.input == s1)
            #expect(error.offset == 5)
            #expect(error.length == 1)
        }
    }

    @Test func testExpectedDescriptorErrorForMissingDescriptor() throws {
        let s1 = "a5,i5,  ,2x"

        do {
            let _ = try FortranFile.format(from: s1)
            Issue.record("Expected descriptor error was not thrown")

        } catch {
            guard let error = error as? FortranFile.FormatError else {
                Issue.record("Unexpected error type")
                return
            }

            #expect(error.kind == .expectedDescriptor)
            #expect(error.input == s1)
            #expect(error.offset == 5)
            #expect(error.length == 1)
        }
    }

    @Test func testExpectedDescriptorErrorForEmptyFormat() throws {
        let s1 = ""

        do {
            let _ = try FortranFile.format(from: s1)
            Issue.record("Expected descriptor error was not thrown")

        } catch {
            guard let error = error as? FortranFile.FormatError else {
                Issue.record("Unexpected error type")
                return
            }

            #expect(error.kind == .expectedDescriptor)
            #expect(error.input == s1)
            #expect(error.offset == 0)
            #expect(error.length == 0)
        }
    }

    @Test func testExpectedDescriptorErrorForUnqualifiedNumber() throws {
        let s1 = "a5,i5,9,2x"

        do {
            let _ = try FortranFile.format(from: s1)
            Issue.record("Expected descriptor error was not thrown")

        } catch {
            guard let error = error as? FortranFile.FormatError else {
                Issue.record("Unexpected error type")
                return
            }

            #expect(error.kind == .expectedDescriptor)
            #expect(error.input == s1)
            #expect(error.offset == 6)
            #expect(error.length == 1)
        }
    }

    @Test func testUnrecognisedDescriptorError() throws {
        let s1 = "a5,i5,2x,y"

        do {
            let _ = try FortranFile.format(from: s1)
            Issue.record("Expected descriptor error was not thrown")

        } catch {
            guard let error = error as? FortranFile.FormatError else {
                Issue.record("Unexpected error type")
                return
            }

            #expect(error.kind == .unrecognisedDescriptor)
            #expect(error.input == s1)
            #expect(error.offset == 9)
            #expect(error.length == 1)
        }
    }

}
