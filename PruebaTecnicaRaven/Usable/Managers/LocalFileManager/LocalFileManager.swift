//
//  FileManager.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 15/10/24.
//

import Foundation

protocol LocalFileManagerProtocol: Sendable {
    func getDocumentsDirectory() async -> URL
    func saveOnDocuments(model: Codable, withName name: String) async throws
    func getModelFromDocuments<T: Codable>(withName name: String) async throws -> T
    func deleteFileFromDocuments(withName name: String) async throws
}

actor LocalFileManager: LocalFileManagerProtocol {
    private let encoder = JSONEncoder()
    nonisolated func getDocumentsDirectory() async -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    nonisolated func saveOnDocuments(model: Codable, withName name: String) async throws {
        let data = try encoder.encode(model)
        let fileURL = await getDocumentsDirectory().appendingPathComponent("\(name).json")
        try data.write(to: fileURL)
    }
    nonisolated func getModelFromDocuments<T: Codable>(withName name: String) async throws -> T {
        let fileURL = await getDocumentsDirectory().appendingPathComponent("\(name).json")
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let model = try decoder.decode(T.self, from: data)
        return model
    }
    func deleteFileFromDocuments(withName name: String) async throws {
        let fileURL = await getDocumentsDirectory().appendingPathComponent("\(name).json")
        guard FileManager.default.fileExists(atPath: fileURL.path()) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }
}
