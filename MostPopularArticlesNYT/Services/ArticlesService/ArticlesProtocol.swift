//
//  ArticlePrototocol.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import Foundation

enum ArticlePeriod: Int, CaseIterable {
    case aDay = 1
    case aWeek = 7
    case aMonth = 30
    func getName() -> String {
        switch self {
        case .aDay: return String(localized: "byDay")
        case .aWeek: return String(localized: "byWeek")
        case .aMonth: return String(localized: "byMonth")
        }
    }
}
enum ArticleShareType: String {
    case facebook = "facebook"
}

protocol ArticlesServiceProtocol: Sendable {
    var keychanAccount: String { get }
    func getEmailedArticles(period: ArticlePeriod) async throws -> GetArticleResponse?
    func getSharedArticles(period: ArticlePeriod) async throws -> GetArticleResponse?
    func getSharedArticles(period: ArticlePeriod,shareType: ArticleShareType) async throws -> GetArticleResponse?
    func getViewedArticles(period: ArticlePeriod) async throws -> GetArticleResponse?
}
