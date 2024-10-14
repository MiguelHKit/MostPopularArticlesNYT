//
//  ArticlesMockService.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import Foundation

// MARK: MOCK Service
actor ArticlesMockService: ArticlesServiceProtocol {
    let keychanAccount = "com.pruebaRaven.apikey"
    func getEmailedArticles(period: ArticlePeriod) async throws -> GetArticleResponse? {
        guard
            let url = Bundle.main.url(forResource: "emailedArticlesResponse", withExtension: "json")
        else { return nil }
        let response: GetArticleResponse = try await NetworkManager.decode(data: Data(contentsOf: url))
        return response
    }
    
    func getSharedArticles(period: ArticlePeriod) async throws -> GetArticleResponse? {
        guard
            let url = Bundle.main.url(forResource: "sharedArticlesResponse", withExtension: "json")
        else { return nil }
        let response: GetArticleResponse = try await NetworkManager.decode(data: Data(contentsOf: url))
        return response
    }
    
    func getSharedArticles(period: ArticlePeriod, shareType: ArticleShareType) async throws -> GetArticleResponse? {
        guard
            let url = Bundle.main.url(forResource: "sharedArticlesWithShareTypeResponse", withExtension: "json")
        else { return nil }
        let response: GetArticleResponse = try await NetworkManager.decode(data: Data(contentsOf: url))
        return response
    }
    
    func getViewedArticles(period: ArticlePeriod) async throws -> GetArticleResponse? {
        guard
            let url = Bundle.main.url(forResource: "viewedArticlesResponse", withExtension: "json")
        else { return nil }
        let response: GetArticleResponse = try await NetworkManager.decode(data: Data(contentsOf: url))
        return response
    }
}
