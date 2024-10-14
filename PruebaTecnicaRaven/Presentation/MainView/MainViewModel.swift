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
    var apiKeyFromKeychain: String? = nil
    @ObservationIgnored private let articlesService: ArticlesServiceProtocol
    
    init(articlesService: ArticlesServiceProtocol = ArticlesService()) {
        self.articlesService = articlesService
        Task { await self.initData() }
    }
    nonisolated func initData() async {
        await MainActor.run { self.isLoading = true }
#if !DEBUG
        await getAPIKeyFromKeychain()
#endif
        await getArticles()
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
            await MainActor.run { [articles] in
                self.articles = articles
            }
        } catch let error as NetworkError {
            await handleNetworkError(error)
        } catch let error as KeychainError {
            await handleKeychainError(error)
        } catch {
            await handleGeneralError(error)
        }
        
    }
    @Sendable
    nonisolated func refreshArticles() async {
        try? await Task.sleep(for: .seconds(1))
        await self.getArticles()
    }
    func resetData() {
        articles.removeAll()
        
    }
    // MARK: KEYCHAIN
    nonisolated func getAPIKeyFromKeychain() async {
        do {
            let apiKey = try await KeychainManager.getAPIKey(for: articlesService.keychanAccount)
            await MainActor.run {
                self.apiKeyFromKeychain = apiKey
            }
        } catch let error as KeychainError {
            await handleKeychainError(error)
        } catch {
            await handleGeneralError(error)
        }
    }
    func saveAPIKeyOnKeychan(_ apiKey: String) async {
        do {
            try await KeychainManager.saveAPIKey(apiKey, for: articlesService.keychanAccount)
        } catch let error as KeychainError {
            handleKeychainError(error)
        } catch {
            handleGeneralError(error)
        }
    }
    func removeKeyFromKeychan() async {
        do {
            try await KeychainManager.deleteAPIKey(for: articlesService.keychanAccount)
        } catch let error as KeychainError {
            handleKeychainError(error)
        } catch {
            handleGeneralError(error)
        }
    }
    // MARK: Handle Error
    func handleNetworkError(_ error: NetworkError) {
        switch error {
        case .custom(let message):
            AlertManager.shared.displayAlert(
                title: NetworkError.generalErrorTitle,
                message: message
            )
        default:
            AlertManager.shared.displayAlert(
                title: NetworkError.generalErrorTitle,
                message: error.localizedDescription()
            )
        }
    }
    func handleKeychainError(_ error: KeychainError) {
        AlertManager.shared.displayAlert(
            title: error.localizedTitle(),
            message: error.localizedDescription()
        )
    }
    func handleGeneralError(_ error: Error) {
        AlertManager.shared.displayAlert(
            title: String(localized: "errorTitle"),
            message: NetworkError.generalErrorMessage
        )
    }
}
