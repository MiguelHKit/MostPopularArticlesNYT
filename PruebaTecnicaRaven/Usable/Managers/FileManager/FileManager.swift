//
//  FileManager.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 15/10/24.
//

import Foundation

actor LocalFileManager {
    static let shared = LocalFileManager()
    private let encoder = JSONEncoder()
    private init() {}
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func saveOnDocuments(model: Codable, withName name: String) throws {
        let data = try encoder.encode(model)
        let fileURL = getDocumentsDirectory().appendingPathComponent("\(name).json")
        try data.write(to: fileURL)
    }
    func getModelFromDocuments<T: Codable>(withName name: String) throws -> T {
        let fileURL = getDocumentsDirectory().appendingPathComponent("\(name).json")
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let model = try decoder.decode(T.self, from: data)
        return model
    }
    func deleteFileFromDocuments(withName name: String) throws {
        let fileURL = getDocumentsDirectory().appendingPathComponent("\(name).json")
        try FileManager.default.removeItem(at: fileURL)
    }
}
