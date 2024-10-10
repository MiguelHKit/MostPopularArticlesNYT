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
    let apiKey: String = ""
    func getEmailedArticles(period: ArticlePeriod) async throws -> ViewedArticleResponse? {
        try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: mainURL,
                    version: .v1,
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
    func getSharedArticles(period: ArticlePeriod) async throws -> ViewedArticleResponse? {
        try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: mainURL,
                    version: .v1,
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
    func getSharedArticles(period: ArticlePeriod, shareType: ArticleShareType) async throws -> ViewedArticleResponse? {
        try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: mainURL,
                    version: .v1,
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
    func getViewedArticles(period: ArticlePeriod) async throws -> ViewedArticleResponse? {
        try await NetworkManager.request(
            request: .init(
                url: .init(
                    baseURL: mainURL,
                    version: .v1,
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
