//
//  ArticlesService.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import Foundation

// MARK: PROD Service
actor ArticlesService: ArticlesServiceProtocol {
    let mainURL: String = NetworkManager.BASE_URL
    let keychanAccount = "com.pruebaRaven.apikey"
    func getEmailedArticles(period: ArticlePeriod) async throws -> GetArticleResponse? {
        let apiKey = try await KeychainManager.getAPIKey(for: keychanAccount)
        return try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: mainURL,
                    version: .v2,
                    path: "emailed/\(period.rawValue).json"
                ),
                method: .get,
                params: [
                    .init(name: "api-key", value: apiKey, on: .query)
                ],
                headers: [],
                body: .none
            )
        )
    }
    func getSharedArticles(period: ArticlePeriod) async throws -> GetArticleResponse? {
        let apiKey = try await KeychainManager.getAPIKey(for: keychanAccount)
        return try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: mainURL,
                    version: .v2,
                    path: "shared/\(period.rawValue).json"
                ),
                method: .get,
                params: [
                    .init(name: "api-key", value: apiKey, on: .query)
                ],
                headers: [],
                body: .none
            )
        )
    }
    func getSharedArticles(period: ArticlePeriod, shareType: ArticleShareType) async throws -> GetArticleResponse? {
        let apiKey = try await KeychainManager.getAPIKey(for: keychanAccount)
        return try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: mainURL,
                    version: .v2,
                    path: "shared/\(period.rawValue)/\(shareType.rawValue).json"
                ),
                method: .get,
                params: [
                    .init(name: "api-key", value: apiKey, on: .query)
                ],
                headers: [],
                body: .none
            )
        )
    }
    func getViewedArticles(period: ArticlePeriod) async throws -> GetArticleResponse? {
        let apiKey = try await KeychainManager.getAPIKey(for: keychanAccount)
        return try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: mainURL,
                    version: .v2,
                    path: "viewed/\(period.rawValue).json"
                ),
                method: .get,
                params: [
                    .init(name: "api-key", value: apiKey, on: .query)
                ],
                headers: [],
                body: .none
            )
        )
    }
}
