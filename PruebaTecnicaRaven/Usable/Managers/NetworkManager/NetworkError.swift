//
//  NetworkError.swift
//  PruebaTecnicaRaven
//
//  Created by Miguel T on 14/10/24.
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
