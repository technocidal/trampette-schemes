import Foundation

extension String {
    
    var normalizedForScoring: String {
        String(lowercased().unicodeScalars)
    }
}
