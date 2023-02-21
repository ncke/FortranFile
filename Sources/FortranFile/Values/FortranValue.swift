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
    public var value: Double
}

public struct FortranInteger: FortranValue {
    public typealias T = Int
    public var value: Int
}

public struct FortranString: FortranValue {
    public typealias T = String
    public var value: String
}

public struct FortranArray: FortranValue {
    public typealias T = [any FortranValue]
    public var value: T
    
    public subscript(index: Int) -> any FortranValue {
        get {
            value[index]
        }
    }
}
