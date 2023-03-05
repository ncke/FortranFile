//
//  Format.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import Foundation

protocol Command {
    init?(prefix: Int?, formatWords: [String])
    func execute(context: inout ReadingContext)
}

protocol Descriptor<Output> {
    associatedtype Output
    init?(formatWords: [String])
    var width: Int { get }
    var canCommaTerminate: Bool { get }
    func translate(from inputString: String) -> Output?
}

extension FortranFile {
    
    public struct Format {
        
        enum FormatItem {
            case command(command: any Command)
            case descriptor(descriptor: any Descriptor, repeatCount: Int)
        }
        
        var items: [FormatItem]
        
    }
    
}
