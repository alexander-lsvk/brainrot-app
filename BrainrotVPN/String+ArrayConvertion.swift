//
//  String+ArrayConvertion.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import Foundation

extension String {
    func splitToArray(separator: Character = ",", trimmingCharacters: CharacterSet? = nil) -> [String] {
        return split(separator: separator)
            .map {
                if let charSet = trimmingCharacters {
                    return $0.trimmingCharacters(in: charSet)
                } else {
                    return String($0)
                }
        }
    }
}

extension Optional where Wrapped == String {
    func splitToArray(separator: Character = ",", trimmingCharacters: CharacterSet? = nil) -> [String] {
        switch self {
        case .none:
            return []
        case .some(let wrapped):
            return wrapped.splitToArray(separator: separator, trimmingCharacters: trimmingCharacters)
        }
    }
}
