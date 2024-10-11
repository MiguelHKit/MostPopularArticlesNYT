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
            var articles: [ArticleModel] = articlesResponse.results?.compactMap {
                ArticleModel(
                    responseId: String($0.id ?? 0),
                    url: $0.url ?? "",
                    adxKeywords: $0.adxKeywords?.components(separatedBy: ";") ?? [],
                    subsection: $0.subsection ?? "",
                    section: $0.section ?? "",
                    nytdsection: $0.nytdsection ?? "",
                    byline: $0.byline ?? "",
                    title: $0.title ?? "",
                    abstract: $0.abstract ?? "",
                    publishedDate: ($0.publishedDate ?? "").toDate(format: .yyyyMMddHHHyphen),
                    updatedDate: ($0.updated ?? "").toDate(format: .yyyyMMddHHmmssHyphen),
                    descriptionFacets: $0.desFacet?.compactMap { $0
                    } ?? [],
                    organizationFacets: $0.orgFacet?.compactMap { $0 } ?? [],
                    personFacets: $0.perFacet?.compactMap { $0 } ?? [],
                    geographycFacets: $0.geoFacet?.compactMap { $0 } ?? [],
                    media: $0.media?.compactMap(
                        { mediaTiem in
                            ArticleModel.Media(
                                caption: mediaTiem.caption ?? "",
                                copyright: mediaTiem.copyright ?? "",
                                approvedForSyndication: mediaTiem.approvedForSyndication == 1 ? true : false,
                                images: mediaTiem.mediaMetadata?.compactMap(
                                    { metaDataItem in
                                        ArticleModel.Media.MediaImage(
                                            url: metaDataItem.url ?? "",
                                            format: (metaDataItem.format ?? "").mapfromNYTAspectRatio(),
                                            width: metaDataItem.width ?? 0,
                                            height: metaDataItem.width ?? 0
                                        )
                                }) ?? []
                            )
                    }) ?? []
                )
            } ?? []
            articles.sort { $0.updatedDate > $1.updatedDate }
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
        await self.getArticles()
    }
}
