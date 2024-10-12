//
//  ArticlesModel.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import Foundation

struct ArticleModel: Identifiable, Hashable {
    static func == (lhs: ArticleModel, rhs: ArticleModel) -> Bool {
        lhs.id == rhs.id
    }
    // MARK: DEFINITION
    let id = UUID()
    // MARK: General
    // id for identifiable
    let responseId: String
    // Article's URL
    let url: String
    // sentenses list of keywords
    let adxKeywords: [String]
    // Article's subsection (e.g. Politics). Can be empty string
    let subsection: String
    // Article's section (e.g. Sports)
    let section : String
    let nytdsection : String
    // eg: By Rhomas L. Friedman
    let byline: String
    // title of article
    let title: String
    // Brief summary of the article
    let abstract: String
    // published date in 2024-10-05 format
    let publishedDate: Date
    // updated date in 2024-10-06 11:21:29 format
    let updatedDate: Date
    // array of description facets (eg: Life and Culture)
    let descriptionFacets: [String]
    let organizationFacets: [String]
    let personFacets: [String]
    let geographycFacets: [String]
    //
    let media: [Self.Media]
    // MARK: Media
    struct Media: Hashable {
        static func == (lhs: ArticleModel.Media, rhs: ArticleModel.Media) -> Bool {
            lhs.id == rhs.id
        }
        let id: UUID = UUID()
        let caption: String
        let copyright: String
        let approvedForSyndication: Bool
        let thumnailImageUrl: URL?
        let images: [Self.MediaImage]
        struct MediaImage: Hashable {
            let url: String
            let format: NYTimageFormat
            let width: Int
            let height: Int
        }
    }
    // MARK: MAPPING
    /// Map the data from GetArticleResponse to a model for view model
    /// - Parameter response: The network model response
    /// - Returns: [ArticleModel]
    static func mapFromService(_ response: GetArticleResponse?) -> [Self] {
        let articlesMapped = (response?.results ?? []).map {
            ArticleModel(
                responseId: String($0.id ?? 0),
                url: $0.url.unwrapped,
                adxKeywords: $0.adxKeywords?.components(separatedBy: ";") ?? [],
                subsection: $0.subsection.unwrapped,
                section: $0.section.unwrapped,
                nytdsection: $0.nytdsection.unwrapped,
                byline: $0.byline.unwrapped,
                title: $0.title.unwrapped,
                abstract: $0.abstract.unwrapped,
                publishedDate: ($0.publishedDate.unwrapped).toDate(format: .yyyyMMddHHHyphen),
                updatedDate: ($0.updated.unwrapped).toDate(format: .yyyyMMddHHmmssHyphen),
                descriptionFacets: $0.desFacet.removeOptionals(),
                organizationFacets: $0.orgFacet.removeOptionals() ,
                personFacets: $0.perFacet.removeOptionals(),
                geographycFacets: $0.geoFacet.removeOptionals(),
                media: Self.mapImagesFromService($0.media.removeOptionals())
            )
        }
        return articlesMapped
    }
    /// Maps the media info separatelly to avoid increase in built time
    /// - Parameter response: the media response from the previous GetArticleItemResponse
    /// - Returns: [GetArticleResponse.Media]
    static func mapImagesFromService(_ response: [GetArticleItemResponse.MediaResponse?]) -> [Self.Media] {
        return response.map {
            let imagesItems = $0?.mediaMetadata?.compactMap { $0 }.map { metaDataItem in
                ArticleModel.Media.MediaImage(
                    url: metaDataItem.url ?? "",
                    format: .mapFromService(metaDataItem.format ?? ""),
                    width: metaDataItem.width ?? 0,
                    height: metaDataItem.width ?? 0
                )
            }
            return ArticleModel.Media(
                caption: $0?.caption ?? "",
                copyright: $0?.copyright ?? "",
                approvedForSyndication: $0?.approvedForSyndication == 1 ? true : false,
                thumnailImageUrl: URL(string: imagesItems?.first(where: { $0.format == .thumnail })?.url ?? ""),
                images: (imagesItems ?? []).filter { $0.format != .thumnail }
            )
        }
    }
}

enum NYTimageFormat {
    case thumnail
    case mediumThreeByTwo210
    case mediumThreeByTwo440
    
    static func mapFromService(_ value: String) -> NYTimageFormat {
        switch value.uppercased() {
        case "standard thumbnail".uppercased(): .thumnail
        case "mediumThreeByTwo210".uppercased(): .mediumThreeByTwo210
        case "mediumThreeByTwo440".uppercased(): .mediumThreeByTwo440
        default: .mediumThreeByTwo440
        }
    }
}
