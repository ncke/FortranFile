import Testing
@testable import FortranFile

// MARK: - Value Test Helpers

func checkLogical(
    _ logical: any FortranFile.Value,
    is booleanExpectation: Bool
) -> Bool {
    guard let logical = logical as? FortranFile.FortranLogical else {
        Issue.record("Expected a FortranLogical")
        return false
    }

    return logical.value == booleanExpectation
}

func checkInteger(
    _ integer: any FortranFile.Value,
    is integerExpectation: Int
) -> Bool {
    guard let integer = integer as? FortranFile.FortranInteger else {
        Issue.record("Expected a FortranInteger")
        return false
    }

    return integer.value == integerExpectation
}

func checkDouble(
    _ double: any FortranFile.Value,
    is doubleExpectation: Double
) -> Bool {
    guard let double = double as? FortranFile.FortranDouble else {
        Issue.record("Expected a FortranDouble")
        return false
    }

    return double.value.isApproximatelyEqual(
        to: doubleExpectation,
        absoluteTolerance: Double.leastNormalMagnitude,
        norm: \.magnitude)
}

func checkString(
    _ string: any FortranFile.Value,
    is stringExpectation: String
) -> Bool {
    guard let string = string as? FortranFile.FortranString else {
        Issue.record("Expected a FortranString")
        return false
    }

    return string.value == stringExpectation
}

func checkArray(
    _ array: any FortranFile.Value
) -> [any FortranFile.Value]? {
    guard let array = array as? FortranFile.FortranArray else {
        Issue.record("Expected a FortranArray")
        return nil
    }

    return array.value
}

// MARK: - Is Approximately Equal

extension AdditiveArithmetic {

    // See: https://github.com/apple/swift-numerics/blob/main/Sources/RealModule/ApproximateEquality.swift#L152
    @inlinable
    public func isApproximatelyEqual<Magnitude>(
        to other: Self,
        absoluteTolerance: Magnitude,
        relativeTolerance: Magnitude = 0,
        norm: (Self) -> Magnitude
    ) -> Bool where Magnitude: FloatingPoint {
        assert(
            absoluteTolerance >= 0 && absoluteTolerance.isFinite,
            "absoluteTolerance should be non-negative and finite, " +
            "but is \(absoluteTolerance)."
        )
        assert(
            relativeTolerance >= 0 && relativeTolerance <= 1,
            "relativeTolerance should be non-negative and <= 1, " +
            "but is \(relativeTolerance)."
        )
        if self == other { return true }
        let delta = norm(self - other)
        let scale = max(norm(self), norm(other))
        let bound = max(absoluteTolerance, scale*relativeTolerance)
        return delta.isFinite && delta <= bound
    }

}
