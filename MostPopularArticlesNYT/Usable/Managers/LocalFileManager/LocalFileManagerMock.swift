//
//  LocalFileManagerMock.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 15/10/24.
//

import Foundation

actor LocalFileManagerMock: LocalFileManagerProtocol {
    func getDocumentsDirectory() async -> URL {
        return URL(string: "www.google.com")!
    }
    
    nonisolated func saveOnDocuments(model: any Codable, withName name: String) async throws {
        
    }
    
    nonisolated func getModelFromDocuments<T: Codable>(withName name: String) async throws -> T {
        guard
            let url = Bundle.main.url(forResource: "sharedArticlesResponse", withExtension: "json")
        else { throw NetworkError.decodingError }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let model = try decoder.decode(T.self, from: data)
        return model
    }
    
    func deleteFileFromDocuments(withName name: String) async throws {
        
    }
}
