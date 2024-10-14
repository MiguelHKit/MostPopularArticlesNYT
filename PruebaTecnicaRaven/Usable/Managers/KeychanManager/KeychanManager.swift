//
//  KeychanMAnager.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 13/10/24.
//

import Foundation

actor KeychainManager {
    // Guardar la API key en el Keychain
    static func saveAPIKey(_ apiKey: String, for account: String) async throws {
        guard let data = apiKey.data(using: .utf8) else { throw KeychainError.invalidData }
        // query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        // Eliminar cualquier entrada anterior
        SecItemDelete(query as CFDictionary)
        // Agregar la nueva entrada
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError.unableToSave
        }
    }

    // Recuperar la API key del Keychain
    static func getAPIKey(for account: String) async throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else {
            throw KeychainError.keyNotFound
        }

        guard let apiKey = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return apiKey
    }

    // Eliminar la API key del Keychain
    static func deleteAPIKey(for account: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            throw KeychainError.unableToDelete
        }
    }
}

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
    func localizedDescription() -> String {
        switch self {
        case .unableToSave: String(localized: "keychainUnableToSave")
        case .keyNotFound: String(localized: "keychainKeyNotFound")
        case .invalidData: String(localized: "keychainInvalidData")
        case .unableToDelete: String(localized: "keychainUnableToDelete")
        }
    }
}
