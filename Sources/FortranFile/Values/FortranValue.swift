//
//  FortranValue.swift
//  
//
//  Created by Nick on 21/02/2023.
//

import Foundation

public protocol FortranValue {
    associatedtype T
    var value: T { get }
}

public struct FortranDouble: FortranValue {
    public typealias T = Double
    public let value: Double
}

public struct FortranInteger: FortranValue {
    public typealias T = Int
    public let value: Int
}

public struct FortranLogical: FortranValue {
    public typealias T = Bool
    public let value: Bool
}

public struct FortranString: FortranValue {
    public typealias T = String
    public let value: String
}

public struct FortranArray: FortranValue {
    public typealias T = [any FortranValue]
    public let value: T
    
    public subscript(index: Int) -> any FortranValue {
        get {
            value[index]
        }
    }
}
