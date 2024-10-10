//
//  ArticlePrototocol.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import Foundation

enum ArticlePeriod: Int {
    case day = 1
    case week = 7
    case month = 30
}
enum ArticleShareType: String {
    case facebook = "facebook"
}

protocol ArticlesServiceProtocol {
    func getEmailedArticles(period: ArticlePeriod) async throws -> ViewedArticleResponse?
    func getSharedArticles(period: ArticlePeriod) async throws -> ViewedArticleResponse?
    func getSharedArticles(period: ArticlePeriod,shareType: ArticleShareType) async throws -> ViewedArticleResponse?
    func getViewedArticles(period: ArticlePeriod) async throws -> ViewedArticleResponse?
}
