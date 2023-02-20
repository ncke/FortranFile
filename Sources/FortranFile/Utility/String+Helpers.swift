//
//  String+Helpers.swift
//  
//
//  Created by Nick on 20/02/2023.
//

import Foundation

extension String {
    
    enum StringError: Error {
        case subscriptOutOfRange
    }
    
    func excerpt(_ n: Int, _ len: Int) throws -> Substring {
        guard
            let excerptStart = self.index(
                self.startIndex,
                offsetBy: n,
                limitedBy: self.endIndex),
            let excerptEnd = self.index(
                self.startIndex,
                offsetBy: n + len,
                limitedBy: self.endIndex)
        else {
            throw StringError.subscriptOutOfRange
        }
        
        return self[excerptStart..<excerptEnd]
    }

}
