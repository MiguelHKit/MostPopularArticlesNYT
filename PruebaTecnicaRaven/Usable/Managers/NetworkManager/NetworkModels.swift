//
//  NetworkModels.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import Foundation

enum NetworkError: Error {
    case badResponse
    case invalidURL
    case invalidResponse
    case urlDoesntExist
    case encodingBodyError
    case decodingError
    case dataError
    case invalidParameters
    case authorizationError
    case URLPathHasNoSlash
    case localRequestError
    case custom(message: String)
    case validationError
    case noData
//    case noModelDefined
    static let generalErrorTitle = String(localized: "generalErrorTitle")
    static let generalErrorMessage = String(localized: "generalErrorMessage")
    
    func localizedDescription() -> String {
        switch self {
        case .badResponse: String(localized: "badResponse")
        case .invalidURL: String(localized: "invalidURL")
        case .invalidResponse: String(localized: "invalidResponse")
        case .urlDoesntExist: String(localized: "urlDoesntExist")
        case .encodingBodyError: String(localized: "encodingBodyError")
        case .decodingError: String(localized: "decodingError")
        case .dataError: String(localized: "dataError")
        case .invalidParameters: String(localized: "invalidParameters")
        case .authorizationError: String(localized: "authorizationError")
        case .URLPathHasNoSlash: String(localized: "URLPathHasNoSlash")
        case .localRequestError: String(localized: "localRequestError")
        case .custom(let message): message
        case .validationError: String(localized: "validationError")
        case .noData: String(localized: "noData")
        }
    }
}

struct ErrorMessageItem: Identifiable {
    let id = UUID()
    let message: String
    let tryAgainAction: (() -> Void)? = nil
}

public typealias Parameters = [String: Any]

struct NetworkResponse {
    let status: Int
    let time: Int
    let size: Int64
    let data: Data
    //    let cookies:
    //    let headers:
    static let empty = Self(status: 0, time: 0, size: 0, data: Data())
    static let status200 = Self(status: 200, time: 0, size: 0, data: Data())
    static let status401 = Self(status: 401, time: 0, size: 0, data: Data())
    static let status429 = Self(status: 429, time: 0, size: 0, data: Data())
    static let status500 = Self(status: 500, time: 0, size: 0, data: Data())
}
