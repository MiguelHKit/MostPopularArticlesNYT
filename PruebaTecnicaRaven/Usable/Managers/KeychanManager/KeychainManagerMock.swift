//
//  KeychainManagerMock.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 15/10/24.
//

import Foundation

actor KeychainManagerMock: KeychainManagerProtocol {
    func saveAPIKey(_ apiKey: String, for account: String) async throws {
        
    }
    
    func getAPIKey(for account: String) async throws -> String {
        return .randomString(length: 10)
    }
    
    func deleteAPIKey(for account: String) async throws {
        
    }
}
