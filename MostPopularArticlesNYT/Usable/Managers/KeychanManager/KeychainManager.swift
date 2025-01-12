//
//  KeychanMAnager.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 13/10/24.
//

import Foundation

protocol KeychainManagerProtocol: Sendable {
    func saveAPIKey(_ apiKey: String, for account: String) async throws
    func getAPIKey(for account: String) async throws -> String
    func deleteAPIKey(for account: String) async throws
}

actor KeychainManager: KeychainManagerProtocol {
    static let shared = KeychainManager()
    private init() { }
    // Guardar la API key en el Keychain
    func saveAPIKey(_ apiKey: String, for account: String) async throws {
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
    func getAPIKey(for account: String) async throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
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
    func deleteAPIKey(for account: String) async throws {
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
