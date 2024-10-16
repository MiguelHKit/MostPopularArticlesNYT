//
//  KeychainError.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 14/10/24.
//

import Foundation

enum KeychainError: Error {
    case unableToSave
    case keyNotFound
    case invalidData
    case unableToDelete
    func localizedTitle() -> String {
        switch self {
        case .unableToSave: String(localized: "errorTitle")
        case .keyNotFound: String(localized: "keychainKeyNotFoundTitle")
        case .invalidData: String(localized: "errorTitle")
        case .unableToDelete: String(localized: "errorTitle")
        }
    }
}

extension KeychainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unableToSave: String(localized: "keychainUnableToSave")
        case .keyNotFound: String(localized: "keychainKeyNotFound")
        case .invalidData: String(localized: "keychainInvalidData")
        case .unableToDelete: String(localized: "keychainUnableToDelete")
        }
    }
}
