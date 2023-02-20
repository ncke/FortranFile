//
//  Format.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import Foundation

// MARK: - Format

extension FortranFile {
    
    public struct Format {
        
        public enum Descriptor {
            case aTextString
            case dDoublePrecision
            case eRealExponent
            case fRealFixedPoint
            case gRealDecimal
            case iInteger
            case xHorizontalSkip
            case pScaleFactor
        }
        
        public struct Item {
            let descriptor: Descriptor
            let repeatFactor: Int?
            let width: Int?
            let decimals: Int?
        }
        
        public let items: [Item]
        
    }
    
}
