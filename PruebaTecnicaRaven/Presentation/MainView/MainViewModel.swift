//
//  MainViewModel.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import Foundation
import SwiftUI
import Observation
import Network
import OSLog

@MainActor
@Observable
final class MainViewModel: Sendable {
    var articles: [ArticleModel] = []
    var isLoading: Bool = true
    var hasInternet: Bool = true
    var periodSelection: ArticlePeriod = .aDay
    var apiKeyFromKeychain: String? = nil
    @ObservationIgnored private let articlesService: ArticlesServiceProtocol
    @ObservationIgnored private let keychainManager: KeychainManagerProtocol
    @ObservationIgnored private let localFileManager: LocalFileManagerProtocol
    @ObservationIgnored private let monitor: NWPathMonitor = NWPathMonitor()
    // MARK: Init
    init(articlesService: ArticlesServiceProtocol = ArticlesService(), keychainManager: KeychainManagerProtocol = KeychainManager.shared, localFileManager: LocalFileManagerProtocol = LocalFileManager()) {
        self.articlesService = articlesService
        self.keychainManager = keychainManager
        self.localFileManager = localFileManager
        Task { await self.initData() }
    }
    nonisolated func initData() async {
        await MainActor.run { self.isLoading = true }
        if await hasInternet {
            await removeArticlesSavedLocally()
            await getAPIKeyFromKeychain()
            await getArticles()
        } else {
            await self.getArticlesSavedLocally()
        }
        await MainActor.run { self.isLoading = false }
        await loadDataImagesForPerformance()
    }
    // MARK: Service
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
        guard await hasInternet else { return }
        try? await Task.sleep(for: .seconds(1))
        await self.getArticles()
    }
    // MARK: Network monitor
    @Sendable
    nonisolated func monitorInternetConectionTask() async {
        for await update in self.monitor {
            let conected = update.status == .satisfied
            await MainActor.run {
                self.hasInternet = conected
            }
        }
    }
    nonisolated func onInternetLost() async {
        await saveArticlesLocally()
        await getArticlesSavedLocally()
    }
    nonisolated func onInternetRestored() async {
        await self.removeArticlesSavedLocally()
        await self.initData()
    }
    // MARK: Common
    deinit { monitor.cancel() }
    func resetData() {
        articles.removeAll()
    }
    nonisolated func loadDataImagesForPerformance() async {
        var articleCopy = await articles
        for article in articleCopy {
            for mediaItem in article.media {
                guard
                let articleIndex = articleCopy.firstIndex(of: article),
                let mediaIndex = article.media.firstIndex(of: mediaItem)
                else { return }
                if let thumbnailStringURL = mediaItem.thumbnailImageURL?.absoluteString {
                    if let thumnailData =  try? await NetworkManager.fetchData(url: thumbnailStringURL), let uiimage = UIImage(data: thumnailData) {
                        articleCopy[articleIndex].media[mediaIndex].thumbnailImageData = uiimage.pngData()
                    }
                }
                if let imageStringURL = mediaItem.largeImageURL?.absoluteString {
                    let ImageData =  try? await NetworkManager.fetchData(url: imageStringURL)
                    articleCopy[articleIndex].media[mediaIndex].largeImageData = ImageData
                }
            }
        }
        os_log("Images loaded with data insted of url")
        await MainActor.run { [articleCopy] in
            self.articles = articleCopy
        }
    }
    // MARK: Keychain
    nonisolated func getAPIKeyFromKeychain() async {
        do {
            let apiKey = try await keychainManager.getAPIKey(for: articlesService.keychanAccount)
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
            try await keychainManager.saveAPIKey(apiKey, for: articlesService.keychanAccount)
        } catch let error as KeychainError {
            handleKeychainError(error)
        } catch {
            handleGeneralError(error)
        }
    }
    func removeAPIKeyFromKeychan() async {
        do {
            try await keychainManager.deleteAPIKey(for: articlesService.keychanAccount)
        } catch let error as KeychainError {
            handleKeychainError(error)
        } catch {
            handleGeneralError(error)
        }
    }
    // MARK: Offline
    nonisolated func saveArticlesLocally() async {
        do {
            guard await articles.isNotEmpty else { return }
            try await localFileManager.saveOnDocuments(model: self.articles, withName: "articles")
            os_log("Saved files locally")
        } catch {
            await handleGeneralError(error)
        }
    }
    nonisolated func getArticlesSavedLocally() async {
        do {
            let localArticlesFetched: [ArticleModel] = try await localFileManager.getModelFromDocuments(withName: "articles")
            await MainActor.run {
                self.articles = localArticlesFetched
            }
        } catch {
            await handleGeneralError(error)
        }
    }
    nonisolated func removeArticlesSavedLocally() async {
        do {
            try await localFileManager.deleteFileFromDocuments(withName: "articles")
            os_log("locally files deleted")
        } catch {
            await handleGeneralError(error)
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
        if error.localizedDescription.isEmpty {
            AlertManager.shared.displayAlert(
                title: String(localized: "errorTitle"),
                message: String(localized: "generalErrorMessage")
            )
        } else {
            AlertManager.shared.displayAlert(
                title: String(localized: "errorTitle"),
                message: error.localizedDescription
            )
        }
    }
}
