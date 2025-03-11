import Foundation

// MARK: - Fortran Values

extension FortranFile {

    public protocol Value: Sendable {
        associatedtype T
        var value: T { get }
    }

    @frozen public struct FortranDouble: Value {
        public typealias T = Double
        public let value: Double
    }

    @frozen public struct FortranInteger: Value {
        public typealias T = Int
        public let value: Int
    }

    @frozen public struct FortranLogical: Value {
        public typealias T = Bool
        public let value: Bool
    }

    @frozen public struct FortranString: Value {
        public typealias T = String
        public let value: String
    }

    @frozen public struct FortranArray: Value {
        public typealias T = [any Value]
        public let value: T

        @inlinable public subscript(index: Int) -> any Value {
            get { value[index] }
        }
    }

}
