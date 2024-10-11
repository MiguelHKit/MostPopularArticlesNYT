//
//  ArticlesModel.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import Foundation

struct ArticleModel: Identifiable {
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
    let media: [Self.Media]
    // MARK: Media
    struct Media {
        let caption: String
        let copyright: String
        let approvedForSyndication: Bool
        let images: [Self.MediaImage]
        struct MediaImage {
            let url: String
            let format: CGFloat
            let width: Int
            let height: Int
        }
    }
}
