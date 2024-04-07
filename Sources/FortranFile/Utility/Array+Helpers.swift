import Foundation

// MARK: - Array Destructuring

extension Array {
    
    var second: Element? { self.count > 1 ? self[1] : nil }
    
    var third: Element? { self.count > 2 ? self[2] : nil }
    
    var fourth: Element? { self.count > 3 ? self[3] : nil }

}

// MARK: - Character Concatenation

extension Array where Element == Character {
    
    func concatenated() -> String {
        self.reduce("") { partial, char in partial + String(char) }
    }
    
}
