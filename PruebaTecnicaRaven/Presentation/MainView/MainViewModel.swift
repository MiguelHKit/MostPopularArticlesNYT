//
//  MainViewModel.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class MainViewModel: Sendable {
    var articles: [ArticleModel] = []
    var isLoading: Bool = true
    var periodSelection: ArticlePeriod = .aDay
    @ObservationIgnored let articlesService: ArticlesServiceProtocol
    
    init(articlesService: ArticlesServiceProtocol = ArticlesMockService()) {
        self.articlesService = articlesService
        Task { await self.initData() }

    }
    nonisolated func initData() async {
        os_log("\(Thread.actualCurrent)")
        await MainActor.run { self.isLoading = true }
        await self.getArticles()
        await MainActor.run { self.isLoading = false }
    }
    nonisolated func getArticles() async {
        do {
            guard
                let articlesResponse = try await self.articlesService.getViewedArticles(period: periodSelection),
                articlesResponse.status?.uppercased() == "OK"
            else { throw NetworkError.noData }
            guard articlesResponse.fault == nil else { throw NetworkError.custom(message: articlesResponse.fault?.faultstring ?? NetworkError.generalErrorMessage) }
            var articles: [ArticleModel] = .Element.mapFromService(articlesResponse)
            articles.sort { $0.updatedDate > $1.updatedDate }
            print("\(articles)")
            await MainActor.run { [articles] in
                self.articles = articles
            }
        } catch let error as NetworkError {
            await MainActor.run {
                switch error {
                case .custom(let message):
                    AlertManager.shared.displayAlert(
                        title: NetworkError.generalErrorTitle,
                        message: message
                    )
                default:
                    AlertManager.shared.displayAlert(
                        title: NetworkError.generalErrorTitle,
                        message: error.localizedDescription
                    )
                }
            }
        } catch {
            await MainActor.run {
                AlertManager.shared.displayAlert(
                    title: NetworkError.generalErrorTitle,
                    message: NetworkError.generalErrorMessage
                )
            }
        }
        
    }
    @Sendable
    nonisolated func refreshArticles() async {
        try? await Task.sleep(for: .seconds(1))
        await self.getArticles()
    }
}
