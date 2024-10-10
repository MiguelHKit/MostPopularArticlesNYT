//
//  ViewedArticleResponse.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 09/10/24.
//

import Foundation

struct FaultResponse: Codable {
    let faultstring: String?
    let detail: FaultErrorCodeResponse?
    struct FaultErrorCodeResponse: Codable {
        let errorcode: String?
    }
}

struct GetArticleResponse: Codable {
    let status: String?
    let copyright: String?
    let num_results: Int?
    let results: GetArticleItemResponse?
    let fault: FaultResponse?
}

struct GetArticleItemResponse: Codable {
    let uri: String?
    let url: String?
    let id, assetID: Int?
    let source: String?
    let publishedDate, updated, section, subsection: String?
    let nytdsection, adxKeywords: String?
    let column: String?//null
    let byline: String?
    let type: String?
    let title, abstract: String?
    let desFacet, orgFacet, perFacet, geoFacet: [String]?
    let media: [MediaResponse]?
    let etaID: Int?
    struct MediaResponse: Codable {
        let type: String?
        let subtype: String?
        let caption: String?
        let copyright: String?
        let approvedForSyndication: Bool?
        let mediaMetadata: [MediaMetadataResponse]?
    }
    struct MediaMetadataResponse: Codable {
        let url: String?
        let format: String?
        let height: Int?
        let width: Int?
    }
}
