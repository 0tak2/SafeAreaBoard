//
//  DomainError.swift
//  SafeAreaBoard
//
//  Created by 임영택 on 4/10/25.
//

import Foundation

enum DomainError: LocalizedError {
    case dataLayerError(String)
    case invalidSession(String)
    
    var errorDescription: String? {
        switch self {
        case .dataLayerError(let message):
            return "Data Layer Error: \(message)"
        case .invalidSession(let message):
            return "Invalid Session: \(message)"
        }
    }
}
